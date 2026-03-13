import express, { Request, Response } from "express";
import cors from 'cors';
import { db, initDb } from "./db";
import "dotenv/config";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

//test-Endpunkt
app.get("/", (req: Request, res: Response) => {
  res.send("Calmly API läuft");
});

type MeditationRow = {
  id: number;
  title: string;
  category: string;
  duration_seconds: number;
};

app.get("/api/meditations", (req, res) => {
  const category =
    typeof req.query.category === "string" && req.query.category.trim() !== ""
      ? req.query.category.trim()
      : null;

  const sql = category
    ? "SELECT id, title, category, duration_seconds FROM meditations WHERE category = ?"
    : "SELECT id, title, category, duration_seconds FROM meditations";
  const params = category ? [category] : [];

  db.all(sql, params, (err, rows: MeditationRow[]) => {
    if (err) {
      console.error("DB error (get meditations):", err);
      res.status(500).json({ error: "DB error" });
      return;
    }

    res.json(
      rows.map((row) => ({
        id: row.id,
        title: row.title,
        category: row.category,
        durationSeconds: row.duration_seconds,
      }))
    );
  });
});

app.get("/api/meditations/:id", (req: Request, res: Response) => {
  const id = Number(req.params.id);
  if (Number.isNaN(id)) {
    res.status(400).json({ error: "Invalid id" });
    return;
  }

  db.get(
    "SELECT id, title, category, duration_seconds FROM meditations WHERE id = ?",
    [id],
    (err, row: any) => {
      if (err) {
        console.error("DB error (get meditation by id):", err);
        res.status(500).json({ error: "DB error" });
        return;
      }

      if (!row) {
        res.status(404).json({ error: "Not found" });
        return;
      }

      res.json({
        id: row.id,
        title: row.title,
        category: row.category,
        durationSeconds: row.duration_seconds,
      });
    }
  );
});

app.post("/api/sessions", (req, res) => {
  const { userId, meditationId, durationSeconds, startedAt, endedAt, completed } = req.body;

  const userIdNum = Number(userId ?? 1);
  const meditationIdNum = Number(meditationId);
  const durationSecondsNum = Number(durationSeconds);
  const completedInt = completed ? 1 : 0;

  if (!Number.isFinite(userIdNum) || userIdNum <= 0) {
    res.status(400).json({ error: "userId must be a valid number" });
    return;
  }

  if (!Number.isFinite(meditationIdNum) || meditationIdNum <= 0) {
    res.status(400).json({ error: "meditationId must be a valid number" });
    return;
  }

  if (!Number.isFinite(durationSecondsNum) || durationSecondsNum <= 0) {
    res.status(400).json({ error: "durationSeconds must be a positive number" });
    return;
  }

  db.get(
    "SELECT id FROM meditations WHERE id = ?",
    [meditationIdNum],
    (checkErr, meditationRow: any) => {
      if (checkErr) {
        console.error("DB error (check meditation):", checkErr);
        res.status(500).json({ error: "DB error" });
        return;
      }

      if (!meditationRow) {
        res.status(400).json({ error: "meditationId does not exist" });
        return;
      }

      const stmt = db.prepare(
        "INSERT INTO sessions (user_id, meditation_id, started_at, ended_at, duration_seconds, completed) VALUES (?, ?, ?, ?, ?, ?)"
      );

      stmt.run(
        userIdNum,
        meditationIdNum,
        startedAt ?? null,
        endedAt ?? null,
        Math.floor(durationSecondsNum),
        completedInt,
        (insertErr: Error | null) => {
          if (insertErr) {
            console.error("DB error (insert session):", insertErr);
            res.status(500).json({ error: "DB error" });
            return;
          }

          res.status(201).json({ saved: true });
        }
      );

      stmt.finalize((finalizeErr) => {
        if (finalizeErr) {
          console.error("DB error (finalize session insert):", finalizeErr);
        }
      });
    }
  );
});

app.get("/api/stats", (req: Request, res: Response) => {
  const userId = Number(typeof req.query.userId === "string" ? req.query.userId : 1);
  if (Number.isNaN(userId)) {
    res.status(400).json({ error: "Invalid userId" });
    return;
  }

  db.get(
    `
    SELECT
      COUNT(*) AS sessionCount,
      COALESCE(SUM(duration_seconds), 0) AS totalSeconds
    FROM sessions
    WHERE user_id = ? AND completed = 1
    `,
    [userId],
    (err, row: any) => {
      if (err) {
        console.error("DB error (stats summary):", err);
        res.status(500).json({ error: "DB error" });
        return;
      }

      const sessionCount = Number(row.sessionCount ?? 0);
      const totalSeconds = Number(row.totalSeconds ?? 0);

      const days: string[] = [];

      db.serialize(() => {
        db.each(
          `
          SELECT DISTINCT date(created_at) AS day
          FROM sessions
          WHERE user_id = ? AND completed = 1
          ORDER BY day DESC
          `,
          [userId],
          (err2, r: any) => {
            if (err2) {
              console.error("DB error (stats days each):", err2);
              res.status(500).json({ error: "DB error" });
              return;
            }
            days.push(r.day);
          },
          (err3) => {
            if (err3) {
              console.error("DB error (stats days complete):", err3);
              res.status(500).json({ error: "DB error" });
              return;
            }

            res.json({
              totalMinutes: Math.floor(totalSeconds / 60),
              sessions: sessionCount,
              streakDays: calcStreak(days),
            });
          }
        );
      });
    }
  );
});

function calcStreak(daysDesc: string[]): number {
  if (daysDesc.length === 0) return 0;

  const daySet = new Set(daysDesc);

  const fmt = (dt: Date) => {
    const y = dt.getFullYear();
    const m = String(dt.getMonth() + 1).padStart(2, "0");
    const d = String(dt.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  };

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let cursor = new Date(today);

  
  if (!daySet.has(fmt(cursor))) {
    cursor.setDate(cursor.getDate() - 1);
  }

  let streak = 0;
  while (daySet.has(fmt(cursor))) {
    streak++;
    cursor.setDate(cursor.getDate() - 1);
  }

  return streak;
}

initDb();

app.listen(PORT, () => {
  console.log(`Server läuft auf Port ${PORT}`);
});

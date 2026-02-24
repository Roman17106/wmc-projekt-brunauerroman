import sqlite3 from "sqlite3";

export const db = new sqlite3.Database("calmly.sqlite");

export function initDb() {
  db.serialize(() => {
    db.run(`
      CREATE TABLE IF NOT EXISTS meditations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        meditation_id INTEGER NOT NULL,
        started_at TEXT,
        ended_at TEXT,
        duration_seconds INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    `);

    // Seed nur wenn meditations leer ist (damit es nicht jedes Mal mehr wird)
    db.get("SELECT COUNT(*) AS cnt FROM meditations", (err, row: any) => {
      if (err) {
        console.error("DB error (count meditations):", err);
        return;
      }

      if (row.cnt === 0) {
        const stmt = db.prepare(
          "INSERT INTO meditations (title, category, duration_seconds) VALUES (?, ?, ?)"
        );

        stmt.run("Morning Focus", "focus", 300);
        stmt.run("Stress Relief", "relax", 600);
        stmt.run("Mindful Breathing", "relax", 420);
        stmt.run("Deep Concentration", "focus", 600);
        stmt.run("Sleep Wind Down", "sleep", 480);

        stmt.finalize();
      }
    });
  });
}
import express from "express";
import cors from "cors";
import { createClient } from "@supabase/supabase-js";
import path from "path";

const app = express();
app.use(cors());
app.use(express.json());

/* Serve frontend */
app.use(express.static("public"));

/* Supabase secure keys in ENV */
const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

/* API endpoint */
app.get("/api/accounts", async (req, res) => {
  const owner = req.query.owner;
  if (!owner) return res.status(400).json({ error: "owner required" });

  const { data, error } = await supabase
    .from("account_stat")
    .select("*")
    .eq("owner_name", owner);

  if (error) return res.status(500).json({ error: error.message });

  res.json(data);
});

/* Fallback: open dashboard */
app.get("*", (req, res) => {
  res.sendFile(path.resolve("public/index.html"));
});

app.listen(process.env.PORT || 3000, () =>
  console.log("Clan Dashboard running...")
);

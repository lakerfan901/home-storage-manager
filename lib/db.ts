import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'home_storage',
  user: process.env.DB_USER || 'storage_user',
  password: process.env.DB_PASSWORD || 'change_me_in_production',
});

export default pool;


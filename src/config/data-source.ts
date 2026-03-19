import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv'; //dotenv is a package that reads your .env file;;;

dotenv.config(); //load all the varibale into the process.env;;;

export const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST,
  port: Number.parseInt(process.env.DB_PORT ?? '3306', 10),
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  entities: ['src/**/*.entity.ts'],
  migrations: ['src/database/migrations/*.ts'],
  synchronize: false,
});

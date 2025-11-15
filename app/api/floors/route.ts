import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET() {
  try {
    const result = await db.query(`
      SELECT 
        f.*,
        COUNT(DISTINCT r.id) as room_count
      FROM floors f
      LEFT JOIN rooms r ON f.id = r.floor_id
      GROUP BY f.id
      ORDER BY f.level ASC
    `)
    
    return NextResponse.json(result.rows.map(row => ({
      ...row,
      room_count: parseInt(row.room_count)
    })))
  } catch (error) {
    console.error('Error fetching floors:', error)
    return NextResponse.json({ error: 'Failed to fetch floors' }, { status: 500 })
  }
}


import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET() {
  try {
    const [boxesResult, itemsResult, roomsResult] = await Promise.all([
      db.query('SELECT COUNT(*) as count FROM boxes'),
      db.query('SELECT COUNT(*) as count FROM items'),
      db.query('SELECT COUNT(*) as count FROM rooms'),
    ])

    return NextResponse.json({
      totalBoxes: parseInt(boxesResult.rows[0].count),
      totalItems: parseInt(itemsResult.rows[0].count),
      totalRooms: parseInt(roomsResult.rows[0].count),
    })
  } catch (error) {
    console.error('Error fetching stats:', error)
    return NextResponse.json({ error: 'Failed to fetch stats' }, { status: 500 })
  }
}


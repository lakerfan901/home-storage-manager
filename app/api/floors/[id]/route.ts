import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const floorResult = await db.query(
      'SELECT * FROM floors WHERE id = $1',
      [params.id]
    )

    if (floorResult.rows.length === 0) {
      return NextResponse.json({ error: 'Floor not found' }, { status: 404 })
    }

    const roomsResult = await db.query(
      `SELECT r.*, COUNT(DISTINCT b.id) as box_count
       FROM rooms r
       LEFT JOIN boxes b ON (b.room_id = r.id OR b.rack_id IN (SELECT id FROM racks WHERE room_id = r.id))
       WHERE r.floor_id = $1
       GROUP BY r.id
       ORDER BY r.name ASC`,
      [params.id]
    )

    return NextResponse.json({
      floor: floorResult.rows[0],
      rooms: roomsResult.rows.map(row => ({
        ...row,
        box_count: parseInt(row.box_count)
      }))
    })
  } catch (error) {
    console.error('Error fetching floor:', error)
    return NextResponse.json({ error: 'Failed to fetch floor' }, { status: 500 })
  }
}


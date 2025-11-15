import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const roomResult = await db.query(
      `SELECT r.*, f.name as floor_name, f.level as floor_level
       FROM rooms r
       JOIN floors f ON r.floor_id = f.id
       WHERE r.id = $1`,
      [params.id]
    )

    if (roomResult.rows.length === 0) {
      return NextResponse.json({ error: 'Room not found' }, { status: 404 })
    }

    const [racksResult, boxesResult] = await Promise.all([
      db.query(
        'SELECT * FROM racks WHERE room_id = $1 ORDER BY name ASC',
        [params.id]
      ),
      db.query(
        'SELECT * FROM boxes WHERE room_id = $1 ORDER BY name ASC',
        [params.id]
      )
    ])

    return NextResponse.json({
      room: roomResult.rows[0],
      racks: racksResult.rows,
      boxes: boxesResult.rows
    })
  } catch (error) {
    console.error('Error fetching room:', error)
    return NextResponse.json({ error: 'Failed to fetch room' }, { status: 500 })
  }
}


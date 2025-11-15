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

export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    const updates: string[] = []
    const values: any[] = []
    let paramCount = 1

    if (body.name !== undefined) {
      updates.push(`name = $${paramCount++}`)
      values.push(body.name)
    }
    if (body.description !== undefined) {
      updates.push(`description = $${paramCount++}`)
      values.push(body.description)
    }

    if (updates.length === 0) {
      return NextResponse.json({ error: 'No fields to update' }, { status: 400 })
    }

    values.push(params.id)
    const result = await db.query(
      `UPDATE rooms SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramCount} RETURNING *`,
      values
    )

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Room not found' }, { status: 404 })
    }

    return NextResponse.json(result.rows[0])
  } catch (error: any) {
    console.error('Error updating room:', error)
    if (error.code === '23505') {
      return NextResponse.json({ error: 'Room name already exists on this floor' }, { status: 400 })
    }
    return NextResponse.json({ error: 'Failed to update room' }, { status: 500 })
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const result = await db.query('DELETE FROM rooms WHERE id = $1 RETURNING *', [params.id])

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Room not found' }, { status: 404 })
    }

    return NextResponse.json({ message: 'Room deleted successfully' })
  } catch (error) {
    console.error('Error deleting room:', error)
    return NextResponse.json({ error: 'Failed to delete room' }, { status: 500 })
  }
}


import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET() {
  try {
    const result = await db.query(`
      SELECT r.*, f.name as floor_name, f.level as floor_level
      FROM rooms r
      JOIN floors f ON r.floor_id = f.id
      ORDER BY f.level ASC, r.name ASC
    `)
    return NextResponse.json(result.rows)
  } catch (error) {
    console.error('Error fetching rooms:', error)
    return NextResponse.json({ error: 'Failed to fetch rooms' }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { floor_id, name, description } = body

    if (!floor_id || !name) {
      return NextResponse.json({ error: 'Floor ID and name are required' }, { status: 400 })
    }

    const result = await db.query(
      `INSERT INTO rooms (floor_id, name, description)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [floor_id, name, description || null]
    )

    return NextResponse.json(result.rows[0], { status: 201 })
  } catch (error: any) {
    console.error('Error creating room:', error)
    if (error.code === '23505') {
      return NextResponse.json({ error: 'Room name already exists on this floor' }, { status: 400 })
    }
    return NextResponse.json({ error: 'Failed to create room' }, { status: 500 })
  }
}

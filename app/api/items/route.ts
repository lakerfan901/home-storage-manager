import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const tag = searchParams.get('tag')
    const boxId = searchParams.get('box_id')

    let query = 'SELECT * FROM item_locations'
    const params: any[] = []
    const conditions: string[] = []

    if (tag) {
      params.push(tag)
      conditions.push(`item_tag = $${params.length}`)
    }

    if (boxId) {
      params.push(boxId)
      conditions.push(`box_id = $${params.length}`)
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ')
    }

    query += ' ORDER BY floor_level, room_name, box_name, item_name'

    const result = await db.query(query, params)
    return NextResponse.json(result.rows)
  } catch (error) {
    console.error('Error fetching items:', error)
    return NextResponse.json({ error: 'Failed to fetch items' }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { box_id, name, description, quantity, tag } = body

    if (!box_id || !name) {
      return NextResponse.json({ error: 'Box ID and name are required' }, { status: 400 })
    }

    const result = await db.query(
      `INSERT INTO items (box_id, name, description, quantity, tag)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [box_id, name, description || null, quantity || 1, tag || null]
    )

    return NextResponse.json(result.rows[0], { status: 201 })
  } catch (error) {
    console.error('Error creating item:', error)
    return NextResponse.json({ error: 'Failed to create item' }, { status: 500 })
  }
}


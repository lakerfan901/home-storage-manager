import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const boxResult = await db.query(
      'SELECT * FROM box_locations WHERE box_id = $1',
      [params.id]
    )

    if (boxResult.rows.length === 0) {
      return NextResponse.json({ error: 'Box not found' }, { status: 404 })
    }

    const itemsResult = await db.query(
      'SELECT * FROM items WHERE box_id = $1 ORDER BY name ASC',
      [params.id]
    )

    return NextResponse.json({
      box: boxResult.rows[0],
      items: itemsResult.rows
    })
  } catch (error) {
    console.error('Error fetching box:', error)
    return NextResponse.json({ error: 'Failed to fetch box' }, { status: 500 })
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
    if (body.room_id !== undefined) {
      updates.push(`room_id = $${paramCount++}`)
      values.push(body.room_id)
      updates.push(`rack_id = NULL`)
    }
    if (body.rack_id !== undefined) {
      updates.push(`rack_id = $${paramCount++}`)
      values.push(body.rack_id)
      updates.push(`room_id = NULL`)
    }

    if (updates.length === 0) {
      return NextResponse.json({ error: 'No fields to update' }, { status: 400 })
    }

    values.push(params.id)
    const result = await db.query(
      `UPDATE boxes SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramCount} RETURNING *`,
      values
    )

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Box not found' }, { status: 404 })
    }

    return NextResponse.json(result.rows[0])
  } catch (error: any) {
    console.error('Error updating box:', error)
    if (error.code === '23505') {
      return NextResponse.json({ error: 'NFC tag ID already exists' }, { status: 400 })
    }
    return NextResponse.json({ error: 'Failed to update box' }, { status: 500 })
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const result = await db.query('DELETE FROM boxes WHERE id = $1 RETURNING *', [params.id])

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Box not found' }, { status: 404 })
    }

    return NextResponse.json({ message: 'Box deleted successfully' })
  } catch (error) {
    console.error('Error deleting box:', error)
    return NextResponse.json({ error: 'Failed to delete box' }, { status: 500 })
  }
}


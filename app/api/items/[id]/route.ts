import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const result = await db.query(
      'SELECT * FROM item_locations WHERE item_id = $1',
      [params.id]
    )

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Item not found' }, { status: 404 })
    }

    return NextResponse.json(result.rows[0])
  } catch (error) {
    console.error('Error fetching item:', error)
    return NextResponse.json({ error: 'Failed to fetch item' }, { status: 500 })
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
    if (body.quantity !== undefined) {
      updates.push(`quantity = $${paramCount++}`)
      values.push(body.quantity)
    }
    if (body.tag !== undefined) {
      updates.push(`tag = $${paramCount++}`)
      values.push(body.tag)
    }

    if (updates.length === 0) {
      return NextResponse.json({ error: 'No fields to update' }, { status: 400 })
    }

    values.push(params.id)
    const result = await db.query(
      `UPDATE items SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    )

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Item not found' }, { status: 404 })
    }

    return NextResponse.json(result.rows[0])
  } catch (error) {
    console.error('Error updating item:', error)
    return NextResponse.json({ error: 'Failed to update item' }, { status: 500 })
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const result = await db.query('DELETE FROM items WHERE id = $1 RETURNING *', [params.id])

    if (result.rows.length === 0) {
      return NextResponse.json({ error: 'Item not found' }, { status: 404 })
    }

    return NextResponse.json({ message: 'Item deleted successfully' })
  } catch (error) {
    console.error('Error deleting item:', error)
    return NextResponse.json({ error: 'Failed to delete item' }, { status: 500 })
  }
}


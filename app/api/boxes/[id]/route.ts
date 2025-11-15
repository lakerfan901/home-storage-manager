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


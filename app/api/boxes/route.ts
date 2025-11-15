import { NextResponse } from 'next/server'
import db from '@/lib/db'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const nfcTagId = searchParams.get('nfc_tag_id')
    
    if (nfcTagId) {
      // Lookup box by NFC tag ID
      const result = await db.query(
        'SELECT * FROM box_locations WHERE nfc_tag_id = $1',
        [nfcTagId]
      )
      
      if (result.rows.length === 0) {
        return NextResponse.json({ error: 'Box not found' }, { status: 404 })
      }
      
      return NextResponse.json(result.rows[0])
    }
    
    // Get all boxes
    const result = await db.query(`
      SELECT * FROM box_locations
      ORDER BY floor_level, room_name, rack_name, box_name
    `)
    return NextResponse.json(result.rows)
  } catch (error) {
    console.error('Error fetching boxes:', error)
    return NextResponse.json({ error: 'Failed to fetch boxes' }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { nfc_tag_id, name, description, room_id, rack_id } = body

    if (!nfc_tag_id) {
      return NextResponse.json({ error: 'NFC tag ID is required' }, { status: 400 })
    }

    const result = await db.query(
      `INSERT INTO boxes (nfc_tag_id, name, description, room_id, rack_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [nfc_tag_id, name || null, description || null, room_id || null, rack_id || null]
    )

    return NextResponse.json(result.rows[0], { status: 201 })
  } catch (error: any) {
    console.error('Error creating box:', error)
    if (error.code === '23505') {
      return NextResponse.json({ error: 'NFC tag ID already exists' }, { status: 400 })
    }
    return NextResponse.json({ error: 'Failed to create box' }, { status: 500 })
  }
}


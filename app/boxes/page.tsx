'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Box, Search, Plus } from 'lucide-react'

interface BoxLocation {
  box_id: string
  nfc_tag_id: string
  box_name?: string
  floor_name: string
  room_name: string
  rack_name?: string
  location_type: string
}

export default function BoxesPage() {
  const router = useRouter()
  const [boxes, setBoxes] = useState<BoxLocation[]>([])
  const [filteredBoxes, setFilteredBoxes] = useState<BoxLocation[]>([])
  const [searchQuery, setSearchQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [showAddBox, setShowAddBox] = useState(false)
  const [rooms, setRooms] = useState<Array<{ id: string; name: string; floor_name: string }>>([])
  const [newBox, setNewBox] = useState({ nfc_tag_id: '', name: '', description: '', room_id: '' })

  useEffect(() => {
    fetchBoxes()
    fetchRooms()
  }, [])

  useEffect(() => {
    if (searchQuery.trim() === '') {
      setFilteredBoxes(boxes)
    } else {
      const query = searchQuery.toLowerCase()
      setFilteredBoxes(
        boxes.filter(
          (box) =>
            box.box_name?.toLowerCase().includes(query) ||
            box.room_name.toLowerCase().includes(query) ||
            box.floor_name.toLowerCase().includes(query) ||
            box.nfc_tag_id.toLowerCase().includes(query)
        )
      )
    }
  }, [searchQuery, boxes])

  const fetchBoxes = async () => {
    try {
      const res = await fetch('/api/boxes')
      const data = await res.json()
      setBoxes(data)
      setFilteredBoxes(data)
    } catch (error) {
      console.error('Error fetching boxes:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchRooms = async () => {
    try {
      const res = await fetch('/api/rooms')
      const data = await res.json()
      setRooms(data)
    } catch (error) {
      console.error('Error fetching rooms:', error)
    }
  }

  const handleAddBox = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newBox.room_id) {
      alert('Please select a room')
      return
    }
    try {
      const res = await fetch('/api/boxes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nfc_tag_id: newBox.nfc_tag_id,
          name: newBox.name || null,
          description: newBox.description || null,
          room_id: newBox.room_id,
        }),
      })
      if (res.ok) {
        setNewBox({ nfc_tag_id: '', name: '', description: '', room_id: '' })
        setShowAddBox(false)
        fetchBoxes()
      } else {
        const error = await res.json()
        alert(error.error || 'Failed to create box')
      }
    } catch (error) {
      console.error('Error adding box:', error)
      alert('Failed to create box')
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 pb-20">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <button
            onClick={() => router.back()}
            className="flex items-center space-x-2 text-gray-600 mb-3"
          >
            <ArrowLeft className="w-5 h-5" aria-hidden="true" />
            <span>Back</span>
          </button>
          <h1 className="text-2xl font-bold text-gray-900 mb-3">All Boxes</h1>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" aria-hidden="true" />
            <input
              type="text"
              placeholder="Search boxes..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-50 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Add Box Form */}
        {showAddBox && (
          <div className="bg-white rounded-xl p-4 shadow-sm mb-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">Add Box</h2>
            <form onSubmit={handleAddBox} className="space-y-3">
              <input
                type="text"
                placeholder="NFC Tag ID *"
                value={newBox.nfc_tag_id}
                onChange={(e) => setNewBox({ ...newBox, nfc_tag_id: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                required
              />
              <input
                type="text"
                placeholder="Box name"
                value={newBox.name}
                onChange={(e) => setNewBox({ ...newBox, name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
              <input
                type="text"
                placeholder="Description"
                value={newBox.description}
                onChange={(e) => setNewBox({ ...newBox, description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
              <select
                value={newBox.room_id}
                onChange={(e) => setNewBox({ ...newBox, room_id: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                required
              >
                <option value="">Select Room *</option>
                {rooms.map((room) => (
                  <option key={room.id} value={room.id}>
                    {room.floor_name} - {room.name}
                  </option>
                ))}
              </select>
              <div className="flex space-x-2">
                <button
                  type="submit"
                  className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                >
                  Add Box
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowAddBox(false)
                    setNewBox({ nfc_tag_id: '', name: '', description: '', room_id: '' })
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg font-medium active:scale-95"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        {/* Add Box Button */}
        {!showAddBox && (
          <div className="mb-4">
            <button
              onClick={() => setShowAddBox(true)}
              className="flex items-center space-x-2 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
            >
              <Plus className="w-4 h-4" aria-hidden="true" />
              <span>Add Box</span>
            </button>
          </div>
        )}
        {loading ? (
          <div className="space-y-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-white rounded-xl p-4 shadow-sm animate-pulse">
                <div className="h-6 bg-gray-200 rounded w-1/3"></div>
              </div>
            ))}
          </div>
        ) : filteredBoxes.length === 0 ? (
          <div className="bg-white rounded-xl p-8 text-center shadow-sm">
            <Box className="w-12 h-12 text-gray-400 mx-auto mb-3" aria-hidden="true" />
            <p className="text-gray-500">
              {searchQuery ? 'No boxes found matching your search' : 'No boxes yet'}
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredBoxes.map((box) => (
              <Link
                key={box.box_id}
                href={`/boxes/${box.box_id}`}
                className="bg-white rounded-xl p-4 shadow-sm active:scale-98 transition-transform block"
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-start space-x-3 flex-1">
                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <Box className="w-5 h-5 text-primary-600" aria-hidden="true" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-semibold text-gray-900 mb-1 truncate">
                        {box.box_name || `Box ${box.nfc_tag_id.slice(0, 8)}`}
                      </div>
                      <div className="text-sm text-gray-600 space-y-0.5">
                        <div className="capitalize">
                          {box.floor_name} → {box.room_name}
                          {box.rack_name && ` → ${box.rack_name}`}
                        </div>
                        <div className="text-xs text-gray-400">NFC: {box.nfc_tag_id}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}


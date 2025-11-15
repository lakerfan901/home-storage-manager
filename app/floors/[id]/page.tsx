'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, DoorOpen, Box, Layers, Plus, Edit2, Trash2 } from 'lucide-react'

interface Room {
  id: string
  name: string
  description?: string
  box_count: number
}

interface Floor {
  id: string
  name: string
  level: number
}

export default function FloorPage() {
  const params = useParams()
  const router = useRouter()
  const [floor, setFloor] = useState<Floor | null>(null)
  const [rooms, setRooms] = useState<Room[]>([])
  const [loading, setLoading] = useState(true)
  const [showAddRoom, setShowAddRoom] = useState(false)
  const [editingRoom, setEditingRoom] = useState<Room | null>(null)
  const [newRoom, setNewRoom] = useState({ name: '', description: '' })

  useEffect(() => {
    fetchFloor()
  }, [params.id])

  const fetchFloor = async () => {
    try {
      const res = await fetch(`/api/floors/${params.id}`)
      const data = await res.json()
      setFloor(data.floor)
      setRooms(data.rooms)
    } catch (error) {
      console.error('Error fetching floor:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAddRoom = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const res = await fetch('/api/rooms', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...newRoom,
          floor_id: params.id,
        }),
      })
      if (res.ok) {
        setNewRoom({ name: '', description: '' })
        setShowAddRoom(false)
        fetchFloor()
      } else {
        const error = await res.json()
        alert(error.error || 'Failed to create room')
      }
    } catch (error) {
      console.error('Error adding room:', error)
      alert('Failed to create room')
    }
  }

  const handleEditRoom = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!editingRoom) return
    try {
      const res = await fetch(`/api/rooms/${editingRoom.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newRoom),
      })
      if (res.ok) {
        setEditingRoom(null)
        setNewRoom({ name: '', description: '' })
        fetchFloor()
      } else {
        const error = await res.json()
        alert(error.error || 'Failed to update room')
      }
    } catch (error) {
      console.error('Error updating room:', error)
      alert('Failed to update room')
    }
  }

  const handleDeleteRoom = async (roomId: string) => {
    if (!confirm('Are you sure you want to delete this room? All boxes and items in this room will also be deleted.')) return
    try {
      const res = await fetch(`/api/rooms/${roomId}`, { method: 'DELETE' })
      if (res.ok) {
        fetchFloor()
      } else {
        alert('Failed to delete room')
      }
    } catch (error) {
      console.error('Error deleting room:', error)
      alert('Failed to delete room')
    }
  }

  const startEdit = (room: Room) => {
    setEditingRoom(room)
    setNewRoom({ name: room.name, description: room.description || '' })
    setShowAddRoom(false)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 pb-20">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <button
            onClick={() => router.back()}
            className="flex items-center space-x-2 text-gray-600 mb-2"
          >
            <ArrowLeft className="w-5 h-5" aria-hidden="true" />
            <span>Back</span>
          </button>
          <h1 className="text-2xl font-bold text-gray-900 capitalize">
            {loading ? 'Loading...' : floor?.name}
          </h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Add/Edit Room Form */}
        {(showAddRoom || editingRoom) && (
          <div className="bg-white rounded-xl p-4 shadow-sm mb-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">
              {editingRoom ? 'Edit Room' : 'Add Room'}
            </h2>
            <form onSubmit={editingRoom ? handleEditRoom : handleAddRoom} className="space-y-3">
              <input
                type="text"
                placeholder="Room name *"
                value={newRoom.name}
                onChange={(e) => setNewRoom({ ...newRoom, name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                required
              />
              <input
                type="text"
                placeholder="Description"
                value={newRoom.description}
                onChange={(e) => setNewRoom({ ...newRoom, description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
              <div className="flex space-x-2">
                <button
                  type="submit"
                  className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                >
                  {editingRoom ? 'Update' : 'Add'} Room
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowAddRoom(false)
                    setEditingRoom(null)
                    setNewRoom({ name: '', description: '' })
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-lg font-medium active:scale-95"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        {/* Add Room Button */}
        {!showAddRoom && !editingRoom && (
          <div className="mb-4">
            <button
              onClick={() => setShowAddRoom(true)}
              className="flex items-center space-x-2 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
            >
              <Plus className="w-4 h-4" aria-hidden="true" />
              <span>Add Room</span>
            </button>
          </div>
        )}

        {loading ? (
          <div className="space-y-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white rounded-xl p-4 shadow-sm animate-pulse">
                <div className="h-6 bg-gray-200 rounded w-1/3"></div>
              </div>
            ))}
          </div>
        ) : rooms.length === 0 ? (
          <div className="bg-white rounded-xl p-8 text-center shadow-sm">
            <DoorOpen className="w-12 h-12 text-gray-400 mx-auto mb-3" aria-hidden="true" />
            <p className="text-gray-500">No rooms on this floor yet</p>
          </div>
        ) : (
          <div className="space-y-3">
            {rooms.map((room) => (
              <div
                key={room.id}
                className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between"
              >
                <Link
                  href={`/rooms/${room.id}`}
                  className="flex items-center space-x-3 flex-1 active:scale-98 transition-transform"
                >
                  <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                    <DoorOpen className="w-5 h-5 text-primary-600" aria-hidden="true" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="font-semibold text-gray-900 truncate">{room.name}</div>
                    {room.description && (
                      <div className="text-sm text-gray-500 truncate">{room.description}</div>
                    )}
                    <div className="text-sm text-gray-500 mt-1">
                      {room.box_count} box{room.box_count !== 1 ? 'es' : ''}
                    </div>
                  </div>
                </Link>
                <div className="flex items-center space-x-2 ml-2">
                  <button
                    onClick={() => startEdit(room)}
                    className="p-2 text-primary-600 active:scale-95"
                    aria-label="Edit room"
                  >
                    <Edit2 className="w-4 h-4" aria-hidden="true" />
                  </button>
                  <button
                    onClick={() => handleDeleteRoom(room.id)}
                    className="p-2 text-red-500 active:scale-95"
                    aria-label="Delete room"
                  >
                    <Trash2 className="w-4 h-4" aria-hidden="true" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}


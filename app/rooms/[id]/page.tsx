'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Box, Layers, Package, Plus, Edit2, Trash2 } from 'lucide-react'

interface Room {
  id: string
  name: string
  description?: string
  floor_name: string
  floor_level: number
}

interface Rack {
  id: string
  name: string
  description?: string
}

interface Box {
  id: string
  nfc_tag_id: string
  name?: string
  description?: string
}

export default function RoomPage() {
  const params = useParams()
  const router = useRouter()
  const [room, setRoom] = useState<Room | null>(null)
  const [racks, setRacks] = useState<Rack[]>([])
  const [boxes, setBoxes] = useState<Box[]>([])
  const [loading, setLoading] = useState(true)
  const [showAddBox, setShowAddBox] = useState(false)
  const [editingBox, setEditingBox] = useState<Box | null>(null)
  const [newBox, setNewBox] = useState({ nfc_tag_id: '', name: '', description: '' })

  useEffect(() => {
    fetchRoom()
  }, [params.id])

  const fetchRoom = async () => {
    try {
      const res = await fetch(`/api/rooms/${params.id}`)
      const data = await res.json()
      setRoom(data.room)
      setRacks(data.racks)
      setBoxes(data.boxes)
    } catch (error) {
      console.error('Error fetching room:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAddBox = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const res = await fetch('/api/boxes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...newBox,
          room_id: params.id,
        }),
      })
      if (res.ok) {
        setNewBox({ nfc_tag_id: '', name: '', description: '' })
        setShowAddBox(false)
        fetchRoom()
      } else {
        const error = await res.json()
        alert(error.error || 'Failed to create box')
      }
    } catch (error) {
      console.error('Error adding box:', error)
      alert('Failed to create box')
    }
  }

  const handleEditBox = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!editingBox) return
    try {
      const res = await fetch(`/api/boxes/${editingBox.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newBox),
      })
      if (res.ok) {
        setEditingBox(null)
        setNewBox({ nfc_tag_id: '', name: '', description: '' })
        fetchRoom()
      } else {
        const error = await res.json()
        alert(error.error || 'Failed to update box')
      }
    } catch (error) {
      console.error('Error updating box:', error)
      alert('Failed to update box')
    }
  }

  const handleDeleteBox = async (boxId: string) => {
    if (!confirm('Are you sure you want to delete this box? All items in this box will also be deleted.')) return
    try {
      const res = await fetch(`/api/boxes/${boxId}`, { method: 'DELETE' })
      if (res.ok) {
        fetchRoom()
      } else {
        alert('Failed to delete box')
      }
    } catch (error) {
      console.error('Error deleting box:', error)
      alert('Failed to delete box')
    }
  }

  const startEditBox = (box: Box) => {
    setEditingBox(box)
    setNewBox({ nfc_tag_id: box.nfc_tag_id, name: box.name || '', description: box.description || '' })
    setShowAddBox(false)
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
          <h1 className="text-2xl font-bold text-gray-900">
            {loading ? 'Loading...' : room?.name}
          </h1>
          {room && (
            <p className="text-sm text-gray-500 capitalize">{room.floor_name} Floor</p>
          )}
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {loading ? (
          <div className="space-y-3">
            {[1, 2].map((i) => (
              <div key={i} className="bg-white rounded-xl p-4 shadow-sm animate-pulse">
                <div className="h-6 bg-gray-200 rounded w-1/3"></div>
              </div>
            ))}
          </div>
        ) : (
          <>
            {/* Racks */}
            {racks.length > 0 && (
              <div className="mb-6">
                <h2 className="text-lg font-semibold text-gray-900 mb-3">Storage Racks</h2>
                <div className="space-y-3">
                  {racks.map((rack) => (
                    <div
                      key={rack.id}
                      className="bg-white rounded-xl p-4 shadow-sm flex items-center space-x-3"
                    >
                      <div className="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center">
                        <Layers className="w-5 h-5 text-indigo-600" aria-hidden="true" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-semibold text-gray-900 truncate">{rack.name}</div>
                        {rack.description && (
                          <div className="text-sm text-gray-500 truncate">{rack.description}</div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Boxes */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h2 className="text-lg font-semibold text-gray-900">
                  Boxes {boxes.length > 0 && `(${boxes.length})`}
                </h2>
                {!showAddBox && !editingBox && (
                  <button
                    onClick={() => setShowAddBox(true)}
                    className="flex items-center space-x-2 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                  >
                    <Plus className="w-4 h-4" aria-hidden="true" />
                    <span>Add Box</span>
                  </button>
                )}
              </div>

              {/* Add/Edit Box Form */}
              {(showAddBox || editingBox) && (
                <div className="bg-white rounded-xl p-4 shadow-sm mb-4">
                  <h3 className="text-md font-semibold text-gray-900 mb-3">
                    {editingBox ? 'Edit Box' : 'Add Box'}
                  </h3>
                  <form onSubmit={editingBox ? handleEditBox : handleAddBox} className="space-y-3">
                    <input
                      type="text"
                      placeholder="NFC Tag ID *"
                      value={newBox.nfc_tag_id}
                      onChange={(e) => setNewBox({ ...newBox, nfc_tag_id: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                      required
                      disabled={!!editingBox}
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
                    <div className="flex space-x-2">
                      <button
                        type="submit"
                        className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                      >
                        {editingBox ? 'Update' : 'Add'} Box
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setShowAddBox(false)
                          setEditingBox(null)
                          setNewBox({ nfc_tag_id: '', name: '', description: '' })
                        }}
                        className="px-4 py-2 border border-gray-300 rounded-lg font-medium active:scale-95"
                      >
                        Cancel
                      </button>
                    </div>
                  </form>
                </div>
              )}

              {boxes.length === 0 ? (
                <div className="bg-white rounded-xl p-8 text-center shadow-sm">
                  <Box className="w-12 h-12 text-gray-400 mx-auto mb-3" aria-hidden="true" />
                  <p className="text-gray-500">No boxes in this room yet</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {boxes.map((box) => (
                    <div
                      key={box.id}
                      className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between"
                    >
                      <Link
                        href={`/boxes/${box.id}`}
                        className="flex items-center space-x-3 flex-1 active:scale-98 transition-transform"
                      >
                        <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                          <Box className="w-5 h-5 text-primary-600" aria-hidden="true" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="font-semibold text-gray-900 truncate">
                            {box.name || `Box ${box.nfc_tag_id.slice(0, 8)}`}
                          </div>
                          {box.description && (
                            <div className="text-sm text-gray-500 truncate">{box.description}</div>
                          )}
                          <div className="text-xs text-gray-400 mt-1 truncate">NFC: {box.nfc_tag_id}</div>
                        </div>
                      </Link>
                      <div className="flex items-center space-x-2 ml-2">
                        <button
                          onClick={() => startEditBox(box)}
                          className="p-2 text-primary-600 active:scale-95"
                          aria-label="Edit box"
                        >
                          <Edit2 className="w-4 h-4" aria-hidden="true" />
                        </button>
                        <button
                          onClick={() => handleDeleteBox(box.id)}
                          className="p-2 text-red-500 active:scale-95"
                          aria-label="Delete box"
                        >
                          <Trash2 className="w-4 h-4" aria-hidden="true" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  )
}


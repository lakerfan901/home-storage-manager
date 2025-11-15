'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Box, Layers, Package } from 'lucide-react'

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

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 pb-20">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <button
            onClick={() => router.back()}
            className="flex items-center space-x-2 text-gray-600 mb-2"
          >
            <ArrowLeft className="w-5 h-5" />
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
                        <Layers className="w-5 h-5 text-indigo-600" />
                      </div>
                      <div className="flex-1">
                        <div className="font-semibold text-gray-900">{rack.name}</div>
                        {rack.description && (
                          <div className="text-sm text-gray-500">{rack.description}</div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Boxes */}
            <div>
              <h2 className="text-lg font-semibold text-gray-900 mb-3">
                Boxes {boxes.length > 0 && `(${boxes.length})`}
              </h2>
              {boxes.length === 0 ? (
                <div className="bg-white rounded-xl p-8 text-center shadow-sm">
                  <Box className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                  <p className="text-gray-500">No boxes in this room yet</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {boxes.map((box) => (
                    <Link
                      key={box.id}
                      href={`/boxes/${box.id}`}
                      className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between active:scale-98 transition-transform block"
                    >
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                          <Box className="w-5 h-5 text-primary-600" />
                        </div>
                        <div>
                          <div className="font-semibold text-gray-900">
                            {box.name || `Box ${box.nfc_tag_id.slice(0, 8)}`}
                          </div>
                          {box.description && (
                            <div className="text-sm text-gray-500">{box.description}</div>
                          )}
                          <div className="text-xs text-gray-400 mt-1">NFC: {box.nfc_tag_id}</div>
                        </div>
                      </div>
                      <Package className="w-5 h-5 text-gray-400" />
                    </Link>
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


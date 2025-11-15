'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, DoorOpen, Box, Layers } from 'lucide-react'

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
          <h1 className="text-2xl font-bold text-gray-900 capitalize">
            {loading ? 'Loading...' : floor?.name}
          </h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
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
            <DoorOpen className="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p className="text-gray-500">No rooms on this floor yet</p>
          </div>
        ) : (
          <div className="space-y-3">
            {rooms.map((room) => (
              <Link
                key={room.id}
                href={`/rooms/${room.id}`}
                className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between active:scale-98 transition-transform block"
              >
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                    <DoorOpen className="w-5 h-5 text-primary-600" />
                  </div>
                  <div>
                    <div className="font-semibold text-gray-900">{room.name}</div>
                    {room.description && (
                      <div className="text-sm text-gray-500">{room.description}</div>
                    )}
                    <div className="text-sm text-gray-500 mt-1">
                      {room.box_count} box{room.box_count !== 1 ? 'es' : ''}
                    </div>
                  </div>
                </div>
                <Box className="w-5 h-5 text-gray-400" />
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}


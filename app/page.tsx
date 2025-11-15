'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Box, Package, Layers, MapPin } from 'lucide-react'

interface Floor {
  id: string
  name: string
  level: number
  room_count?: number
}

export default function Home() {
  const [floors, setFloors] = useState<Floor[]>([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalBoxes: 0,
    totalItems: 0,
    totalRooms: 0,
  })

  useEffect(() => {
    fetchFloors()
    fetchStats()
  }, [])

  const fetchFloors = async () => {
    try {
      const res = await fetch('/api/floors')
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({ error: 'Failed to fetch floors' }))
        console.error('Error fetching floors:', errorData)
        setFloors([])
        return
      }
      const data = await res.json()
      setFloors(data)
    } catch (error) {
      console.error('Error fetching floors:', error)
      setFloors([])
    } finally {
      setLoading(false)
    }
  }

  const fetchStats = async () => {
    try {
      const res = await fetch('/api/stats')
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({ error: 'Failed to fetch stats' }))
        console.error('Error fetching stats:', errorData)
        setStats({ totalBoxes: 0, totalItems: 0, totalRooms: 0 })
        return
      }
      const data = await res.json()
      setStats(data)
    } catch (error) {
      console.error('Error fetching stats:', error)
      setStats({ totalBoxes: 0, totalItems: 0, totalRooms: 0 })
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 pb-20">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-gray-900">Home Storage</h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Stats Cards */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          <div className="bg-white rounded-xl p-4 shadow-sm">
            <div className="text-2xl font-bold text-gray-900">{stats.totalRooms}</div>
            <div className="text-xs text-gray-500 mt-1">Rooms</div>
          </div>
          <div className="bg-white rounded-xl p-4 shadow-sm">
            <div className="text-2xl font-bold text-gray-900">{stats.totalBoxes}</div>
            <div className="text-xs text-gray-500 mt-1">Boxes</div>
          </div>
          <div className="bg-white rounded-xl p-4 shadow-sm">
            <div className="text-2xl font-bold text-gray-900">{stats.totalItems}</div>
            <div className="text-xs text-gray-500 mt-1">Items</div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-3">
            <Link
              href="/boxes"
              className="bg-white rounded-xl p-4 shadow-sm flex items-center space-x-3 active:scale-95 transition-transform"
            >
              <Box className="w-6 h-6 text-primary-600" />
              <span className="font-medium text-gray-900">View Boxes</span>
            </Link>
            <Link
              href="/items"
              className="bg-white rounded-xl p-4 shadow-sm flex items-center space-x-3 active:scale-95 transition-transform"
            >
              <Package className="w-6 h-6 text-primary-600" />
              <span className="font-medium text-gray-900">View Items</span>
            </Link>
          </div>
        </div>

        {/* Floors */}
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Floors</h2>
          {loading ? (
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="bg-white rounded-xl p-4 shadow-sm animate-pulse">
                  <div className="h-6 bg-gray-200 rounded w-1/3"></div>
                </div>
              ))}
            </div>
          ) : (
            <div className="space-y-3">
              {floors.map((floor) => (
                <Link
                  key={floor.id}
                  href={`/floors/${floor.id}`}
                  className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between active:scale-98 transition-transform block"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                      <Layers className="w-5 h-5 text-primary-600" />
                    </div>
                    <div>
                      <div className="font-semibold text-gray-900 capitalize">{floor.name}</div>
                      {floor.room_count !== undefined && (
                        <div className="text-sm text-gray-500">{floor.room_count} room{floor.room_count !== 1 ? 's' : ''}</div>
                      )}
                    </div>
                  </div>
                  <MapPin className="w-5 h-5 text-gray-400" />
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}


'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Database, Info } from 'lucide-react'

interface DatabaseInfo {
  version: string
  database: string
  uptime?: string
}

export default function SettingsPage() {
  const router = useRouter()
  const [dbInfo, setDbInfo] = useState<DatabaseInfo | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDbInfo()
  }, [])

  const fetchDbInfo = async () => {
    try {
      // Get basic database info
      const res = await fetch('/api/stats')
      if (res.ok) {
        // For now, just show that connection works
        setDbInfo({
          version: 'PostgreSQL 16',
          database: 'home_storage',
        })
      }
    } catch (error) {
      console.error('Error fetching database info:', error)
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
            <ArrowLeft className="w-5 h-5" aria-hidden="true" />
            <span>Back</span>
          </button>
          <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Database Info */}
        <div className="bg-white rounded-xl p-6 shadow-sm mb-6">
          <div className="flex items-center space-x-3 mb-4">
            <Database className="w-6 h-6 text-primary-600" aria-hidden="true" />
            <h2 className="text-lg font-semibold text-gray-900">Database Information</h2>
          </div>
          {loading ? (
            <div className="space-y-2">
              <div className="h-4 bg-gray-200 rounded w-1/3 animate-pulse"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2 animate-pulse"></div>
            </div>
          ) : dbInfo ? (
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-600">Version:</span>
                <span className="font-medium text-gray-900">{dbInfo.version}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Database:</span>
                <span className="font-medium text-gray-900">{dbInfo.database}</span>
              </div>
            </div>
          ) : (
            <p className="text-sm text-gray-500">Unable to fetch database information</p>
          )}
        </div>

        {/* App Info */}
        <div className="bg-white rounded-xl p-6 shadow-sm mb-6">
          <div className="flex items-center space-x-3 mb-4">
            <Info className="w-6 h-6 text-primary-600" aria-hidden="true" />
            <h2 className="text-lg font-semibold text-gray-900">Application Information</h2>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Version:</span>
              <span className="font-medium text-gray-900">1.0.0</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Framework:</span>
              <span className="font-medium text-gray-900">Next.js 14</span>
            </div>
          </div>
        </div>

        {/* Future Sections Placeholder */}
        <div className="bg-white rounded-xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900 mb-2">Coming Soon</h2>
          <p className="text-sm text-gray-500">
            Additional settings and configuration options will be available here.
          </p>
        </div>
      </div>
    </div>
  )
}


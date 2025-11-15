'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft, Package, Search, Tag } from 'lucide-react'

interface ItemLocation {
  item_id: string
  item_name: string
  item_description?: string
  quantity: number
  item_tag?: string
  box_id: string
  box_name?: string
  floor_name: string
  room_name: string
  rack_name?: string
}

export default function ItemsPage() {
  const router = useRouter()
  const [items, setItems] = useState<ItemLocation[]>([])
  const [filteredItems, setFilteredItems] = useState<ItemLocation[]>([])
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedTag, setSelectedTag] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [tags, setTags] = useState<string[]>([])

  useEffect(() => {
    fetchItems()
  }, [])

  useEffect(() => {
    let filtered = items

    if (searchQuery.trim() !== '') {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (item) =>
          item.item_name.toLowerCase().includes(query) ||
          item.item_description?.toLowerCase().includes(query) ||
          item.box_name?.toLowerCase().includes(query) ||
          item.room_name.toLowerCase().includes(query)
      )
    }

    if (selectedTag) {
      filtered = filtered.filter((item) => item.item_tag === selectedTag)
    }

    setFilteredItems(filtered)
  }, [searchQuery, selectedTag, items])

  const fetchItems = async () => {
    try {
      const res = await fetch('/api/items')
      const data = await res.json()
      setItems(data)
      setFilteredItems(data)
      
      // Extract unique tags
      const uniqueTags = Array.from(
        new Set(data.map((item: ItemLocation) => item.item_tag).filter(Boolean))
      ) as string[]
      setTags(uniqueTags.sort())
    } catch (error) {
      console.error('Error fetching items:', error)
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
            className="flex items-center space-x-2 text-gray-600 mb-3"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Back</span>
          </button>
          <h1 className="text-2xl font-bold text-gray-900 mb-3">All Items</h1>
          <div className="relative mb-3">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search items..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-50 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
          {tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              <button
                onClick={() => setSelectedTag(null)}
                className={`px-3 py-1 rounded-full text-sm font-medium ${
                  selectedTag === null
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700'
                }`}
              >
                All
              </button>
              {tags.map((tag) => (
                <button
                  key={tag}
                  onClick={() => setSelectedTag(tag)}
                  className={`px-3 py-1 rounded-full text-sm font-medium flex items-center space-x-1 ${
                    selectedTag === tag
                      ? 'bg-primary-600 text-white'
                      : 'bg-gray-100 text-gray-700'
                  }`}
                >
                  <Tag className="w-3 h-3" />
                  <span>{tag}</span>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-6">
        {loading ? (
          <div className="space-y-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-white rounded-xl p-4 shadow-sm animate-pulse">
                <div className="h-6 bg-gray-200 rounded w-1/3"></div>
              </div>
            ))}
          </div>
        ) : filteredItems.length === 0 ? (
          <div className="bg-white rounded-xl p-8 text-center shadow-sm">
            <Package className="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p className="text-gray-500">
              {searchQuery || selectedTag
                ? 'No items found matching your filters'
                : 'No items yet'}
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredItems.map((item) => (
              <Link
                key={item.item_id}
                href={`/boxes/${item.box_id}`}
                className="bg-white rounded-xl p-4 shadow-sm active:scale-98 transition-transform block"
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-start space-x-3 flex-1">
                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <Package className="w-5 h-5 text-primary-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center space-x-2 mb-1">
                        <div className="font-semibold text-gray-900">{item.item_name}</div>
                        {item.quantity > 1 && (
                          <span className="bg-primary-100 text-primary-700 text-xs px-2 py-0.5 rounded-full">
                            x{item.quantity}
                          </span>
                        )}
                        {item.item_tag && (
                          <span className="bg-gray-100 text-gray-600 text-xs px-2 py-0.5 rounded-full">
                            {item.item_tag}
                          </span>
                        )}
                      </div>
                      {item.item_description && (
                        <div className="text-sm text-gray-600 mb-1">{item.item_description}</div>
                      )}
                      <div className="text-xs text-gray-500 capitalize">
                        {item.floor_name} → {item.room_name}
                        {item.rack_name && ` → ${item.rack_name}`} →{' '}
                        {item.box_name || 'Box'}
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


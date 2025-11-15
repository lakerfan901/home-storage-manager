'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { ArrowLeft, Package, Plus, Edit2, Trash2 } from 'lucide-react'

interface Item {
  id: string
  name: string
  description?: string
  quantity: number
  tag?: string
}

interface Box {
  box_id: string
  nfc_tag_id: string
  box_name?: string
  floor_name: string
  room_name: string
  rack_name?: string
}

export default function BoxPage() {
  const params = useParams()
  const router = useRouter()
  const [box, setBox] = useState<Box | null>(null)
  const [items, setItems] = useState<Item[]>([])
  const [loading, setLoading] = useState(true)
  const [showAddItem, setShowAddItem] = useState(false)
  const [newItem, setNewItem] = useState({ name: '', description: '', quantity: 1, tag: '' })

  useEffect(() => {
    fetchBox()
  }, [params.id])

  const fetchBox = async () => {
    try {
      const res = await fetch(`/api/boxes/${params.id}`)
      const data = await res.json()
      setBox(data.box)
      setItems(data.items)
    } catch (error) {
      console.error('Error fetching box:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAddItem = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const res = await fetch('/api/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...newItem,
          box_id: params.id,
          quantity: parseInt(newItem.quantity.toString()) || 1,
        }),
      })
      if (res.ok) {
        setNewItem({ name: '', description: '', quantity: 1, tag: '' })
        setShowAddItem(false)
        fetchBox()
      }
    } catch (error) {
      console.error('Error adding item:', error)
    }
  }

  const handleDeleteItem = async (itemId: string) => {
    if (!confirm('Are you sure you want to delete this item?')) return
    try {
      const res = await fetch(`/api/items/${itemId}`, { method: 'DELETE' })
      if (res.ok) {
        fetchBox()
      }
    } catch (error) {
      console.error('Error deleting item:', error)
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
            {loading ? 'Loading...' : box?.box_name || `Box ${box?.nfc_tag_id.slice(0, 8)}`}
          </h1>
          {box && (
            <p className="text-sm text-gray-500 capitalize">
              {box.floor_name} → {box.room_name}
              {box.rack_name && ` → ${box.rack_name}`}
            </p>
          )}
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
        ) : (
          <>
            {/* Add Item Form */}
            {showAddItem && (
              <div className="bg-white rounded-xl p-4 shadow-sm mb-4">
                <form onSubmit={handleAddItem} className="space-y-3">
                  <input
                    type="text"
                    placeholder="Item name *"
                    value={newItem.name}
                    onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    required
                  />
                  <input
                    type="text"
                    placeholder="Description"
                    value={newItem.description}
                    onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                  <div className="grid grid-cols-2 gap-3">
                    <input
                      type="number"
                      placeholder="Quantity"
                      value={newItem.quantity}
                      onChange={(e) =>
                        setNewItem({ ...newItem, quantity: parseInt(e.target.value) || 1 })
                      }
                      min="1"
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    />
                    <input
                      type="text"
                      placeholder="Tag"
                      value={newItem.tag}
                      onChange={(e) => setNewItem({ ...newItem, tag: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    />
                  </div>
                  <div className="flex space-x-2">
                    <button
                      type="submit"
                      className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                    >
                      Add Item
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setShowAddItem(false)
                        setNewItem({ name: '', description: '', quantity: 1, tag: '' })
                      }}
                      className="px-4 py-2 border border-gray-300 rounded-lg font-medium active:scale-95"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Items */}
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-lg font-semibold text-gray-900">
                Items {items.length > 0 && `(${items.length})`}
              </h2>
              {!showAddItem && (
                <button
                  onClick={() => setShowAddItem(true)}
                  className="flex items-center space-x-2 bg-primary-600 text-white px-4 py-2 rounded-lg font-medium active:scale-95"
                >
                  <Plus className="w-4 h-4" />
                  <span>Add Item</span>
                </button>
              )}
            </div>

            {items.length === 0 ? (
              <div className="bg-white rounded-xl p-8 text-center shadow-sm">
                <Package className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                <p className="text-gray-500">No items in this box yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {items.map((item) => (
                  <div
                    key={item.id}
                    className="bg-white rounded-xl p-4 shadow-sm flex items-start justify-between"
                  >
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <div className="font-semibold text-gray-900">{item.name}</div>
                        {item.quantity > 1 && (
                          <span className="bg-primary-100 text-primary-700 text-xs px-2 py-0.5 rounded-full">
                            x{item.quantity}
                          </span>
                        )}
                        {item.tag && (
                          <span className="bg-gray-100 text-gray-600 text-xs px-2 py-0.5 rounded-full">
                            {item.tag}
                          </span>
                        )}
                      </div>
                      {item.description && (
                        <div className="text-sm text-gray-600">{item.description}</div>
                      )}
                    </div>
                    <button
                      onClick={() => handleDeleteItem(item.id)}
                      className="p-2 text-red-500 active:scale-95"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}


import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import Link from 'next/link'
import { Home, Box, Settings } from 'lucide-react'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Home Storage Manager',
  description: 'Manage your home storage across floors, rooms, racks, and boxes',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes',
  themeColor: '#0ea5e9',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'Storage Manager',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
        {/* Bottom Navigation */}
        <footer className="fixed bottom-0 inset-x-0 bg-white border-t border-gray-200 py-2 z-20">
          <div className="max-w-4xl mx-auto flex justify-around">
            <Link
              href="/"
              className="flex flex-col items-center space-y-1 px-4 py-2 text-xs text-gray-600 active:text-primary-600 transition-colors"
            >
              <Home className="w-5 h-5" aria-hidden="true" />
              <span>Home</span>
            </Link>
            <Link
              href="/boxes"
              className="flex flex-col items-center space-y-1 px-4 py-2 text-xs text-gray-600 active:text-primary-600 transition-colors"
            >
              <Box className="w-5 h-5" aria-hidden="true" />
              <span>Boxes</span>
            </Link>
            <Link
              href="/settings"
              className="flex flex-col items-center space-y-1 px-4 py-2 text-xs text-gray-600 active:text-primary-600 transition-colors"
            >
              <Settings className="w-5 h-5" aria-hidden="true" />
              <span>Settings</span>
            </Link>
          </div>
        </footer>
      </body>
    </html>
  )
}


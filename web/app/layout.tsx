import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'AItherworks - Brass & Steam Edition',
  description: 'A steampunk puzzle-sim where you build and train minds of gears and aether',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  )
}


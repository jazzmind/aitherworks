'use client'

import { useEffect, useRef, useState } from 'react'

export default function GamePage() {
  const [status, setStatus] = useState('Initializing...')
  const [progress, setProgress] = useState(0)
  const [isLoading, setIsLoading] = useState(true)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    let engine: any = null

    const startGame = async () => {
      try {
        // @ts-ignore - Godot engine globals
        const Engine = window.Engine

        if (!Engine) {
          throw new Error('Godot Engine not loaded')
        }

        engine = new Engine({
          canvas: canvasRef.current,
          onProgress: (current: number, total: number) => {
            if (total > 0) {
              const percentage = Math.round((current / total) * 100)
              setProgress(percentage)
              setStatus(`Loading... ${percentage}%`)
            }
          },
          onPrint: (text: string) => {
            console.log('[Godot]', text)
          },
          onPrintError: (text: string) => {
            console.error('[Godot Error]', text)
          },
        })

        setStatus('Starting engine...')
        await engine.startGame({
          executable: '/godot/aitherworks',
          mainPack: '/godot/aitherworks.pck',
        })

        setIsLoading(false)
        setStatus('')
      } catch (error) {
        console.error('Failed to start game:', error)
        setStatus('Failed to load game. Please refresh.')
      }
    }

    startGame()

    return () => {
      if (engine) {
        engine.requestQuit()
      }
    }
  }, [])

  return (
    <div id="game-container">
      <canvas ref={canvasRef} id="canvas" />
      {isLoading && (
        <div id="status">
          <div>
            <div id="status-progress" style={{ display: progress > 0 ? 'block' : 'none' }}>
              <div id="status-progress-inner" style={{ width: `${progress}%` }} />
            </div>
            <div id="status-indeterminate" style={{ display: progress === 0 ? 'block' : 'none' }}>
              <div></div>
              <div></div>
              <div></div>
              <div></div>
              <div></div>
              <div></div>
              <div></div>
              <div></div>
            </div>
            <div id="status-notice">{status}</div>
          </div>
        </div>
      )}
    </div>
  )
}


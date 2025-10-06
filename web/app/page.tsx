'use client'

import { useEffect, useRef, useState } from 'react'

declare global {
  interface Window {
    Engine?: any
  }
}

export default function GamePage() {
  const [status, setStatus] = useState('Checking for game files...')
  const [progress, setProgress] = useState(0)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    let engine: any = null

    const loadEngineScript = (): Promise<void> => {
      return new Promise((resolve, reject) => {
        // Check if game files exist
        fetch('/godot/aitherworks.js')
          .then(response => {
            if (!response.ok) {
              throw new Error('Game files not found')
            }
            
            const script = document.createElement('script')
            script.src = '/godot/aitherworks.js'
            script.async = true
            script.onload = () => resolve()
            script.onerror = () => reject(new Error('Failed to load game engine'))
            document.body.appendChild(script)
          })
          .catch(reject)
      })
    }

    const startGame = async () => {
      try {
        setStatus('Loading game engine...')
        
        // Load the Godot engine script
        await loadEngineScript()

        // Wait a bit for the engine to initialize
        await new Promise(resolve => setTimeout(resolve, 100))

        const Engine = window.Engine

        if (!Engine) {
          throw new Error('Godot Engine not initialized. Make sure you ran: ./scripts/export_web.sh')
        }

        setStatus('Initializing engine...')

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

        setStatus('Starting game...')
        await engine.startGame({
          executable: '/godot/aitherworks',
          mainPack: '/godot/aitherworks.pck',
        })

        setIsLoading(false)
        setStatus('')
      } catch (err) {
        console.error('Failed to start game:', err)
        const errorMessage = err instanceof Error ? err.message : 'Unknown error'
        
        if (errorMessage.includes('not found')) {
          setError('Game files not found. Please run: ./scripts/export_web.sh')
          setStatus('⚠️ Game not exported yet')
        } else {
          setError(errorMessage)
          setStatus('Failed to load game')
        }
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
            {error ? (
              <div id="status-notice" style={{ color: '#D4AF37', maxWidth: '600px' }}>
                <div style={{ fontSize: '18px', marginBottom: '20px' }}>⚠️ {status}</div>
                <div style={{ fontSize: '14px', marginBottom: '20px' }}>{error}</div>
                <div style={{ fontSize: '12px', color: '#888', lineHeight: '1.6' }}>
                  <strong>Steps to fix:</strong>
                  <ol style={{ textAlign: 'left', marginTop: '10px' }}>
                    <li>Open a terminal in the project root</li>
                    <li>Run: <code style={{ background: '#333', padding: '2px 6px', borderRadius: '3px' }}>./scripts/export_web.sh</code></li>
                    <li>Wait for export to complete</li>
                    <li>Refresh this page</li>
                  </ol>
                </div>
              </div>
            ) : (
              <>
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
              </>
            )}
          </div>
        </div>
      )}
    </div>
  )
}


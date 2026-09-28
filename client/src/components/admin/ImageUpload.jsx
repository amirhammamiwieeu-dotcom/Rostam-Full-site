import { useState, useRef } from 'react'
import { Upload, X, Image as ImageIcon, Loader } from 'lucide-react'
import toast from 'react-hot-toast'
import { api } from '../../lib/api'

export default function ImageUpload({ value, onChange, multiple = false, max = 5 }) {
  const [uploading, setUploading] = useState(false)
  const inputRef = useRef(null)

  const images = multiple ? (Array.isArray(value) ? value : []) : (value ? [value] : [])

  const handleFiles = async (files) => {
    if (!files || files.length === 0) return

    setUploading(true)
    try {
      const formData = new FormData()
      if (multiple) {
        Array.from(files).slice(0, max - images.length).forEach((f) => {
          formData.append('files', f)
        })
        const res = await api.post('/upload/images', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
        const urls = (res.data.files || []).map((f) => f.url)
        onChange([...images, ...urls])
      } else {
        formData.append('file', files[0])
        const res = await api.post('/upload/image', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
        onChange(res.data.url)
      }
      toast.success('Uploaded successfully')
    } catch (err) {
      console.error(err)
      toast.error(err.message || 'Upload failed')
    } finally {
      setUploading(false)
      if (inputRef.current) inputRef.current.value = ''
    }
  }

  const handleRemove = (url) => {
    if (multiple) {
      onChange(images.filter((u) => u !== url))
    } else {
      onChange('')
    }
  }

  return (
    <div>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        multiple={multiple}
        onChange={(e) => handleFiles(e.target.files)}
        className="hidden"
      />

      <div className="flex flex-wrap gap-3">
        {images.map((url, i) => (
          <div
            key={i}
            className="relative w-24 h-24 rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-secondary"
          >
            <img src={url} alt="" className="w-full h-full object-contain" />
            <button
              type="button"
              onClick={() => handleRemove(url)}
              className="absolute top-1 right-1 w-5 h-5 rounded-full bg-danger text-white flex items-center justify-center hover:bg-red-700 transition"
            >
              <X className="h-3 w-3" />
            </button>
          </div>
        ))}

        {(!multiple ? images.length === 0 : images.length < max) && (
          <button
            type="button"
            onClick={() => inputRef.current?.click()}
            disabled={uploading}
            className="w-24 h-24 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-700 flex flex-col items-center justify-center gap-1 hover:border-primary hover:bg-primary/5 transition text-gray-400 hover:text-primary disabled:opacity-50"
          >
            {uploading ? (
              <Loader className="h-5 w-5 animate-spin" />
            ) : (
              <>
                <Upload className="h-5 w-5" />
                <span className="text-[10px] font-medium">Upload</span>
              </>
            )}
          </button>
        )}
      </div>

      {multiple && (
        <p className="text-xs text-gray-500 mt-2">
          {images.length} / {max} images
        </p>
      )}
    </div>
  )
}

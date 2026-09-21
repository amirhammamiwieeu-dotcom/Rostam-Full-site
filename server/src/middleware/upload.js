import multer from 'multer'
import { ApiError } from '../utils/ApiError.js'

// Memory storage — we forward buffer to Supabase
const storage = multer.memoryStorage()

const ALLOWED_IMAGE_TYPES = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/gif',
]

const fileFilter = (req, file, cb) => {
  if (ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(ApiError.badRequest('Only image files are allowed (jpeg, png, webp, gif)'), false)
  }
}

export const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
    files: 10,
  },
  fileFilter,
})
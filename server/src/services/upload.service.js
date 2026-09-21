import { supabaseAdmin } from '../config/supabase.js'
import { ApiError } from '../utils/ApiError.js'
import { generateRandomString } from '../utils/helpers.js'

const BUCKET = 'products'

/**
 * Upload a file buffer to Supabase Storage
 */
export const uploadFile = async (file, folder = 'products') => {
  if (!file) throw ApiError.badRequest('No file provided')

  const ext = file.originalname.split('.').pop() || 'jpg'
  const filename = `${folder}/${Date.now()}-${generateRandomString(8)}.${ext}`

  const { error: uploadError } = await supabaseAdmin.storage
    .from(BUCKET)
    .upload(filename, file.buffer, {
      contentType: file.mimetype,
      upsert: false,
    })

  if (uploadError) {
    console.error('Supabase upload error:', uploadError)
    throw ApiError.badRequest(uploadError.message)
  }

  const { data } = supabaseAdmin.storage.from(BUCKET).getPublicUrl(filename)

  return {
    url: data.publicUrl,
    path: filename,
    size: file.size,
    mimetype: file.mimetype,
  }
}

/**
 * Upload multiple files
 */
export const uploadFiles = async (files, folder = 'products') => {
  if (!files || files.length === 0) return []
  const results = await Promise.all(files.map((f) => uploadFile(f, folder)))
  return results
}

/**
 * Delete a file from storage
 */
export const deleteFile = async (path) => {
  const { error } = await supabaseAdmin.storage.from(BUCKET).remove([path])
  if (error) throw ApiError.badRequest(error.message)
  return { success: true }
}
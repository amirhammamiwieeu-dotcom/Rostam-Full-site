import { asyncHandler } from '../utils/asyncHandler.js'
import { ApiResponse } from '../utils/ApiResponse.js'
import { uploadFile, uploadFiles, deleteFile } from '../services/upload.service.js'
import { ApiError } from '../utils/ApiError.js'

export const uploadSingle = asyncHandler(async (req, res) => {
  if (!req.file) throw ApiError.badRequest('No file uploaded')
  const result = await uploadFile(req.file, req.query.folder || 'products')
  return ApiResponse.created(res, result, 'File uploaded')
})

export const uploadMultiple = asyncHandler(async (req, res) => {
  if (!req.files?.length) throw ApiError.badRequest('No files uploaded')
  const results = await uploadFiles(req.files, req.query.folder || 'products')
  return ApiResponse.created(res, { files: results }, 'Files uploaded')
})

export const removeFile = asyncHandler(async (req, res) => {
  const path = req.query.path
  if (!path) throw ApiError.badRequest('Path required')
  await deleteFile(path)
  return ApiResponse.success(res, null, 'File deleted')
})
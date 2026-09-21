export class ApiResponse {
  constructor(statusCode, data, message = 'Success') {
    this.statusCode = statusCode
    this.data = data
    this.message = message
    this.success = statusCode < 400
  }

  static success(res, data, message = 'Success', statusCode = 200) {
    return res.status(statusCode).json({
      success: true,
      message,
      data,
    })
  }

  static created(res, data, message = 'Created successfully') {
    return res.status(201).json({
      success: true,
      message,
      data,
    })
  }

  static error(res, message, statusCode = 500, details = null) {
    return res.status(statusCode).json({
      success: false,
      message,
      ...(details && { details }),
    })
  }
}

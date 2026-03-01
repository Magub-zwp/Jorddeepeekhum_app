# Parking App Backend Setup Guide

## Requirements
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache with mod_rewrite enabled

## Installation Steps

### 1. Setup PHP Server
- Place the `backend` folder in your web server's directory (e.g., `htdocs` for XAMPP)
- The typical path would be: `C:\xampp\htdocs\parking_app`

### 2. Create Database
- Open phpMyAdmin or MySQL client
- Create a new database named `parking_app_db`:
  ```sql
  CREATE DATABASE parking_app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  ```

### 3. Initialize Database Tables
- Option A: Using phpMyAdmin
  - Import the `backend/init_db.php` file or manually run the SQL queries
  
- Option B: Using PHP CLI
  ```bash
  php backend/init_db.php
  ```
  
- Option C: Run the setup script via browser
  - Navigate to: `http://localhost/parking_app/init_db.php`

### 4. Configure API Service in Flutter
- Update the `baseUrl` in `lib/services/api_service.dart`:
  ```dart
  static const String baseUrl = 'http://localhost/parking_app/api';
  ```
  
- If using a different host/port, adjust accordingly

### 5. File Structure
```
backend/
├── .htaccess              # URL rewriting configuration
├── config.php             # Database connection configuration
├── init_db.php            # Database initialization script
└── api/
    ├── users.php          # User CRUD operations
    ├── vehicles.php       # Vehicle CRUD operations
    ├── parking_lots.php   # Parking lot CRUD operations
    ├── parking_spots.php  # Parking spot CRUD operations
    └── bookings.php       # Booking CRUD operations
```

## API Endpoints

### Users
- **Register**: `POST /api/users.php`
- **Login**: `POST /api/users.php`
- **Get User**: `GET /api/users.php?id={userId}`
- **Update User**: `PUT /api/users.php?id={userId}`
- **Delete User**: `DELETE /api/users.php?id={userId}`

### Vehicles
- **Add Vehicle**: `POST /api/vehicles.php`
- **Get Vehicle**: `GET /api/vehicles.php?id={vehicleId}`
- **Get User Vehicles**: `GET /api/vehicles.php?user_id={userId}`
- **Update Vehicle**: `PUT /api/vehicles.php?id={vehicleId}`
- **Delete Vehicle**: `DELETE /api/vehicles.php?id={vehicleId}`

### Parking Lots
- **Get All Lots**: `GET /api/parking_lots.php`
- **Get Lot**: `GET /api/parking_lots.php?id={lotId}`
- **Add Lot**: `POST /api/parking_lots.php`
- **Update Lot**: `PUT /api/parking_lots.php?id={lotId}`

### Parking Spots
- **Get Spots by Lot**: `GET /api/parking_spots.php?lot_id={lotId}`
- **Get Spot**: `GET /api/parking_spots.php?id={spotId}`
- **Add Spot**: `POST /api/parking_spots.php`
- **Update Spot**: `PUT /api/parking_spots.php?id={spotId}`

### Bookings
- **Get User Bookings**: `GET /api/bookings.php?user_id={userId}`
- **Get Booking**: `GET /api/bookings.php?id={bookingId}`
- **Create Booking**: `POST /api/bookings.php`
- **Update Booking**: `PUT /api/bookings.php?id={bookingId}`
- **Delete Booking**: `DELETE /api/bookings.php?id={bookingId}`

## Database Configuration
Edit `backend/config.php` to match your database settings:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Your MySQL password
define('DB_NAME', 'parking_app_db');
```

## Testing the API
Use Postman or similar tool to test endpoints:

**Example: Register User**
```
URL: http://localhost/parking_app/api/users.php
Method: POST
Headers: Content-Type: application/json
Body:
{
  "username": "testuser",
  "email": "test@example.com",
  "phone": "0812345678",
  "password": "password123"
}
```

## Troubleshooting

### "Database connection failed"
- Verify MySQL is running
- Check database credentials in `config.php`
- Ensure `parking_app_db` exists

### "Method not allowed"
- Check that the request method (GET/POST/PUT/DELETE) is correct
- Verify .htaccess is properly configured

### CORS Issues
- The `config.php` includes CORS headers for cross-origin requests
- Adjust them if needed for production

## Security Notes
- This is a development setup; for production use:
  - Use environment variables for database credentials
  - Implement proper authentication (JWT tokens)
  - Add input validation and sanitization
  - Use HTTPS
  - Implement rate limiting
  - Add proper error handling without exposing sensitive info

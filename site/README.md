# site Web API

This is a .NET 8 Web API application that provides HTTP services for product management.

## Building the Application

To build the application for Linux deployment:

```powershell
./build.ps1
```

This will create a self-contained, trimmed executable in the `dist` folder.

## Running on Linux

1. Copy the `site` executable to your Linux server
2. Set execute permissions:
   ```bash
   chmod +x site
   ```
3. Run the application:
   ```bash
   ./site
   ```

The application will listen on port 8080 by default.

## API Endpoints

### Products API
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get a specific product
- `POST /api/products` - Create a new product
- `PUT /api/products/{id}` - Update a product
- `DELETE /api/products/{id}` - Delete a product

### Weather Forecast API
- `GET /weatherforecast` - Sample weather forecast endpoint

## Configuration

The application uses SQLite for data storage. The database file (`app.db`) will be created automatically.
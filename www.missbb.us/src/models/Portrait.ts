export interface Portrait {
  id: string;
  name: string;
  age: number;
  nationality: string;
  height: string; // e.g., "165cm"
  weight: string; // e.g., "48kg"
  bloodType: string; // e.g., "A"
  bust: string; // e.g., "85cm"
  locations: string[]; // e.g., ["Tokyo", "Osaka", "Kyoto"]
  description: string;
  imageUrl: string;
  thumbnailUrl?: string;
  photos: string[]; // Array of photo URLs for the gallery
  videos?: string[]; // Array of video URLs for the gallery (optional)
}
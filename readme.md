# Custom Note Service with Supabase

A minimal notes service backend built with Supabase.

## Schema Design Explanation

- **Primary Key**: UUID `id` - Provides globally unique identifiers without risk of collision
- **user_id**: References auth.users - Ties each note to a specific user
- **title**: TEXT with NOT NULL - Ensures every note has at least a title
- **content**: TEXT (nullable) - Allows for empty content
- **created_at/updated_at**: Automatic timestamps - Helps with sorting and tracking changes
- **is_public**: BOOLEAN with default false - Allows for future public/private note functionality
- **Row Level Security**: Ensures users can only access their own notes

## Endpoints

### POST /notes
- **Why POST?**: Creating a resource
- **Why /notes?**: RESTful convention for notes collection
- **Params in body**: JSON with title, content, is_public - Standard for resource creation

### GET /notes
- **Why GET?**: Retrieving resources
- **Why /notes?**: RESTful convention for notes collection
- **No params needed**: Uses auth token to identify user

## Setup & Deployment

1. Create a new Supabase project
2. Run the SQL from `schema.sql` in the SQL editor
3. Set up environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anon/public key
4. Deploy functions:
   ```bash
   supabase functions deploy post_notes --no-verify-jwt
   supabase functions deploy get_notes --no-verify-jwt

## Demo Tests: 
0. First create a user manually in Autentication/users with testing email:test@example.com , password: 123456
1. get_token.ps1 : Run the file with your user's email and password to get access token to create post and get notes.
2. test_notes.ps1: Run the file with your input  title/content , it will add the note and save access token for future note add on. Returns json object to confirm note insertion in notes table.
3. get_user_notes: Run the file to get all the user specific notes in json objects, copies to clipboard and saves a file locally for future use cases.
## Inputs:
To see the input open the powershell files-> get_token, test_notes, get_user_notes.
## Outputs:
1. ./get_token.ps1     
Attempting to sign in...
Successfully signed in!
Access Token: eyJhbGciOiJIUzI1NiIsImtpZCI6IkJTa0FOc09GbU81dlhJQjEiLCJ0eXAiOiJKV1QifQ........

2. ./test_notes.ps1

Create New Note
---------------
Enter note title (required): Second Note
Enter note content (optional): These is the second Note.
Make note public? (y/N): y
{
    "status":  "success",
    "timestamp":  "2025-04-27 18:43:57",
    "message":  "Note created successfully!",
    "note":  {
                 "id":  "597190f2-bf4d-432c-bc6e-ac4030aa6fa6",
                 "user_id":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                 "title":  "Second Note",
                 "content":  "These is the second Note.",
                 "created_at":  "2025-04-27T13:13:59.564379+00:00",
                 "updated_at":  "2025-04-27T13:13:59.564379+00:00",
                 "is_public":  true
             }
}

All Your Notes
--------------

Title              Created          ID
-----              -------          --
Second Note        27-04-2025 18:43 597190f2...
First Note         27-04-2025 18:37 548ba4f2...
My PowerShell Note 27-04-2025 18:10 ff030834...
My PowerShell Note 27-04-2025 18:08 4e5d3d64...



Create another note? (Y/n): n

Session complete. Your access token remains valid for future use.

3.  ./get_user_notes.ps1
{
    "metadata":  {
                     "timestamp":  "2025-04-27T18:44:43+05:30",
                     "userId":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                     "noteCount":  4
                 },
    "notes":  {
                  "value":  [
                                {
                                    "id":  "597190f2-bf4d-432c-bc6e-ac4030aa6fa6",
                                    "user_id":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                                    "title":  "Second Note",
                                    "content":  "These is the second Note.",
                                    "created_at":  "2025-04-27T13:13:59.564379+00:00",
                                    "updated_at":  "2025-04-27T13:13:59.564379+00:00",
                                    "is_public":  true
                                },
                                {
                                    "id":  "548ba4f2-fd77-44d7-a308-bccb4f46dbb8",
                                    "user_id":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                                    "title":  "First Note",
                                    "content":  "Welcome to the custom note service",
                                    "created_at":  "2025-04-27T13:07:39.164073+00:00",
                                    "updated_at":  "2025-04-27T13:07:39.164073+00:00",
                                    "is_public":  true
                                },
                                {
                                    "id":  "ff030834-52ac-4e4a-a691-0df4ba23b66c",
                                    "user_id":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                                    "title":  "My PowerShell Note",
                                    "content":  "Created via PowerShell script",
                                    "created_at":  "2025-04-27T12:40:38.982159+00:00",
                                    "updated_at":  "2025-04-27T12:40:38.982159+00:00",
                                    "is_public":  false
                                },
                                {
                                    "id":  "4e5d3d64-d146-4f50-9c37-e96698212aeb",
                                    "user_id":  "be8159a5-36ff-4067-ac3a-8ead8102617c",
                                    "title":  "My PowerShell Note",
                                    "content":  "Created via PowerShell script",
                                    "created_at":  "2025-04-27T12:38:41.968894+00:00",
                                    "updated_at":  "2025-04-27T12:38:41.968894+00:00",
                                    "is_public":  false
                                }
                            ],
                  "Count":  4
              }
}

Note data has been copied to your clipboard.
Saved to user_notes_20250427_184443.json
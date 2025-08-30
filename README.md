# InkBlade
A Windows desktop manga/comic reader and library manager built with Flutter. <br/>
Import, organize, and read your collection with ease.
---
## ✨ Features
- **📚 Library**
  - Searchable library
  - Infinite scroll with smooth hover and click effects
  - Adjustable page count badges (position + font size)
  - Floating Import button for adding new books
<img width="2560" height="1540" alt="library1" src="https://github.com/user-attachments/assets/267d8e3b-8504-4941-9eb5-de2d688e30ca" />

- **➕ Import**
  - User can import new books to their library from here
  - Book metadata can be modified before importing
<img width="2560" height="1540" alt="import6" src="https://github.com/user-attachments/assets/18480f4a-4721-498b-9b4e-28d545eb74e9" />

- **📝 Book Management**  
  - Click cover image to start reading from first page
  - Editable fields: Title, Series, Link, Authors, Tags, Characters
  - Saved/unsaved edits highlighted (green = saved, red = unsaved)
  - Add/remove authors, tags, and characters via text fields with dropdown suggestions (keyboard or mouse navigation)
  - Authors, Tags, Characters chips can be clicked to go to their respective pages
  - Favorite & Read Later flags
  - Delete book button
  - Reveal folder in Explorer button
  - Page preview grid with numbered, clickable thumbnails
  - Ctrl+Click the link field to open it in your browser
  - 'ESC' hotkey to exit book page
<img width="2560" height="1540" alt="bookdescription1" src="https://github.com/user-attachments/assets/4444c8ab-3de8-46ef-9f5f-cd62cea00149" />

- **📖 Reader**  
  - Navigation:
      - Left/Right arrows or A/D -> Previous/Next page
      - Up/Down arrows or W/S -> Scroll when zoomed
  - Quick-jump to any page via page counter
  - Zoom controls, first/last page buttons
<img width="2560" height="1540" alt="bookreader2" src="https://github.com/user-attachments/assets/453ccacc-b15d-4213-8f31-199bcf9f33b2" />

- **✍️ Authors**  
  - Searchable author list with infinite scroll
  - Resizable author buttons (via settings)
  - Author page:
    - Rename with save/unsaved color indicators
    - Delete button removes author from all books (does not delete books)
<img width="2560" height="1540" alt="authors1" src="https://github.com/user-attachments/assets/f59c2bea-ff6c-4039-b627-0bd34e7eedb2" />
<img width="2560" height="1540" alt="authorspage1" src="https://github.com/user-attachments/assets/7622952f-1707-4008-ab93-088bad2d9cbc" />


- **🏷️ Tags**
  - Searchable tags with infinite scroll
  - Resizable tag buttons (via settings)
  - Customizable tag thumbnails
  - Tag page:
      - Rename with save/unsaved color indicators
      - Delete button removes tag from all books (does not delete books)
<img width="2560" height="1540" alt="tags1" src="https://github.com/user-attachments/assets/3c03495d-5957-402e-a96a-1cd2ed1cd05b" />
<img width="2560" height="1540" alt="tagspage1" src="https://github.com/user-attachments/assets/9e8c6e28-8cc2-4124-8b06-88d77cd7618f" />

- **📚 Series**
  - Searchable series list with book counts
  - Series page:
    - Rename with save/unsaved color indicators
    - Delete button removes series from all books (does not delete books)
<img width="2560" height="1540" alt="series" src="https://github.com/user-attachments/assets/f2f75790-beb5-416f-8200-b482e7b1f399" />
<img width="2560" height="1540" alt="seriespage" src="https://github.com/user-attachments/assets/40f87164-5311-48e9-83d2-a69e0f4de415" />

- **👤 Characters**
  - Searchable character list with book counts
  - Character page:
    - Rename with save/unsaved color indicators
    - Delete button removes character from all books (does not delete books)
<img width="2560" height="1540" alt="characters" src="https://github.com/user-attachments/assets/bf5c2e6a-4c28-4307-a23a-728086b4830f" />
<img width="2560" height="1540" alt="characterspage" src="https://github.com/user-attachments/assets/971b9332-dcb9-4894-8510-dd9b978d6892" />

- **⭐ Drawer**
  - Favorites – books marked as favorites
  - Read Later – books marked to read later
  - Series – jump into series pages
  - Characters – jump into character pages
<img width="2560" height="1540" alt="favorites" src="https://github.com/user-attachments/assets/7fc2c374-c375-433b-b784-dcb19bbbcd22" />
<img width="2560" height="1540" alt="readlater" src="https://github.com/user-attachments/assets/80050fe0-43c5-474c-aa0f-c19582b4b159" />

- **⚙️ Settings**
  - Delete book on import toggle (removes source folder after import)
  - Start zoomed toggle for reader
  - Pages per row slider for book description previews
  - Badge position dropdown: Off / TL / TR / BL / BR
  - Badge font size slider
  - Author button size slider
  - Tag button size slider
<img width="2560" height="1540" alt="settings" src="https://github.com/user-attachments/assets/2e461190-65c2-42db-a7dd-e0a004f8babd" />

- **❓ FAQ**
  - Q: How do I install InkBlade?
    - A: Download the release .zip, extract it, and run "InkBlade.exe".

  - Q: Where does InkBlade store its files?
    - A: InkBlade stores all files inside "/Documents/InkBlade"

  - Q: Does InkBlade support other operating systems (Mac/Linux)?
    - A: Inkblade has only been tested for Windows.

  - Q: What file formats does InkBlade support?
    - A: When importing you must select a folder with files that contain the following types:
      - ".jpg", ".png", ".webp"

  - Q: How do I import a book?
    - A: Follow these steps:
      - Click on the Floating Action Button on the bottom right from the home screen.
      - Click the big plus button on the left and select the directory where the book you wish to import is.
      - Input your metadata.
      - Click Import.

  - Q: Why is the Import book button greyed out?
    - A: There are two causes
      - The directory selected does not contain a valid file format.
      - The name supplied for the book already exists in your library.

  - Q: How do I jump to a specific page while reading?
      - A: Click the page counter at the top and enter the page number.

  - Q: How can I backup my library?
    - A: Yes, copy "/Documents/InkBlade".

  - Q: How can I restore my library?
    - A: Copy your backed up version to "/Documents/InkBlade" and select "Replace files in the destination".

  - Q: Does Inkblade require an internet connection?
    - A: No, Inkblade functions completely offline.
---

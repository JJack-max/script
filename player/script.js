// TikTok Style Video Player

let currentVideoIndex = 0;
let videoData = [];

// Fetch video data from external JSON file
async function fetchVideoData() {
    try {
        const response = await fetch('videos.json');
        videoData = await response.json();
        return videoData;
    } catch (error) {
        console.error('Failed to fetch video data:', error);
        // Fallback to hardcoded data if fetch fails
        videoData = [
            {
                id: 1,
                url: "https://s3.missbb.us/Learn_English_with_Taylor_Swift_Talk_Show.mp4",
                author: "Official Source",
                description: "Learn English with Taylor Swift Talk Show.",
                music: "Original Sound",
                likes: "125K",
                comments: "2.3K",
                shares: "50K"
            },
            {
                id: 2,
                url: "https://s3.missbb.us/Use_Strategic_Thinking_to_Create_the_Life_You.mp4",
                author: "Official Source",
                description: "Use Strategic Thinking to Create the Life You.",
                music: "Original Sound",
                likes: "125K",
                comments: "2.3K",
                shares: "50K"
            },
            {
                id: 3,
                url: "https://s3.missbb.us/President_Obama_Makes_Historic_Speech_to_America's_Students.mp4",
                author: "Official Source",
                description: "President Obama makes a historic speech to America's students about education and future.",
                music: "Original Sound",
                likes: "125K",
                comments: "2.3K",
                shares: "50K"
            },
            {
                id: 4,
                url: "https://s3.missbb.us/Admiral_McRaven_addresses_the_University_of_Texas_at_Austin_Class_of_2014.mp4",
                author: "Admiral McRaven",
                description: "Admiral McRaven addresses the University of Texas at Austin Class of 2014 with inspiring words.",
                music: "Original Sound",
                likes: "89K",
                comments: "1.8K",
                shares: "32K"
            }
        ];
        return videoData;
    }
}

// Initialize the player
async function initPlayer() {
    await fetchVideoData();
    createVideoElements();
    setupEventListeners();
}

// Create video elements
function createVideoElements() {
    const videoFeed = document.getElementById('videoFeed');

    // Clear existing content
    videoFeed.innerHTML = '';

    videoData.forEach((video, index) => {
        const videoItem = document.createElement('div');
        videoItem.className = 'video-item';
        videoItem.innerHTML = `
            <video class="video-player" playsinline webkit-playsinline>
                <source src="${video.url}" type="video/mp4">
                Your browser does not support the video tag.
            </video>
            <div class="video-overlay">
                <div class="video-info">
                    <div class="video-author">
                        <div class="author-avatar"></div>
                        <div class="author-name">${video.author}</div>
                    </div>
                    <div class="video-description">${video.description}</div>
                    <div class="music-info">
                        <div class="music-icon">♪</div>
                        <div class="music-text">${video.music}</div>
                    </div>
                </div>
                <div class="actions">
                    <div class="action-button like-button">
                        <div class="action-icon">❤️</div>
                        <div class="action-count">${video.likes}</div>
                    </div>
                    <div class="action-button comment-button">
                        <div class="action-icon">💬</div>
                        <div class="action-count">${video.comments}</div>
                    </div>
                    <div class="action-button share-button">
                        <div class="action-icon">↗️</div>
                        <div class="action-count">${video.shares}</div>
                    </div>
                    <div class="user-avatar"></div>
                </div>
            </div>
        `;

        videoFeed.appendChild(videoItem);
    });

    // Setup video players
    setupVideoPlayers();
}

// Setup video players
function setupVideoPlayers() {
    const videoItems = document.querySelectorAll('.video-item');

    videoItems.forEach((item, index) => {
        const video = item.querySelector('.video-player');

        // Play video when it comes into view
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    // Pause all videos
                    document.querySelectorAll('.video-player').forEach(v => {
                        v.pause();
                    });

                    // Play the current video
                    video.play().catch(e => console.log("Autoplay prevented:", e));
                }
            });
        }, {
            threshold: 0.5 // Play when 50% of the video is visible
        });

        observer.observe(item);

        // Handle video click to play/pause (like TikTok)
        video.addEventListener('click', () => {
            if (video.paused) {
                video.play();
            } else {
                video.pause();
            }
        });

        // Handle like button
        const likeButton = item.querySelector('.like-button');
        likeButton.addEventListener('click', (e) => {
            e.stopPropagation();
            const icon = likeButton.querySelector('.action-icon');
            const count = likeButton.querySelector('.action-count');

            if (icon.textContent === '❤️') {
                icon.textContent = '❤️';
                // You could add actual like functionality here
            }
        });

        // Handle comment button
        const commentButton = item.querySelector('.comment-button');
        commentButton.addEventListener('click', (e) => {
            e.stopPropagation();
            // You could add comment functionality here
        });

        // Handle share button
        const shareButton = item.querySelector('.share-button');
        shareButton.addEventListener('click', (e) => {
            e.stopPropagation();
            // You could add share functionality here
        });
    });
}

// Setup event listeners
function setupEventListeners() {
    // Handle scroll snap events
    const videoFeed = document.getElementById('videoFeed');

    videoFeed.addEventListener('scroll', () => {
        // Throttle scroll events
        if (!window.scrollThrottle) {
            window.scrollThrottle = true;
            setTimeout(() => {
                window.scrollThrottle = false;
            }, 100);

            // Handle scroll-based logic here if needed
        }
    });
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', initPlayer);

// Add periodic refresh to check for video updates
setInterval(async () => {
    const oldVideoCount = videoData.length;
    await fetchVideoData();

    // If video count or any video URL changed, refresh the player
    if (videoData.length !== oldVideoCount ||
        videoData.some((video, index) => video.url !== (videoData[index] ? videoData[index].url : null))) {
        createVideoElements();
    }
}, 30000); // Check for updates every 30 seconds
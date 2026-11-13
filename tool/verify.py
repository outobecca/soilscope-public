from playwright.sync_api import sync_playwright
import os
import glob

def run_cuj(page):
    print("Navigating to app...")
    page.goto("http://localhost:3000")
    page.wait_for_timeout(8000) # Give Flutter web time to load

    print("Taking initial screenshot...")
    page.screenshot(path="/home/jules/verification/screenshots/verification_initial.png")

    print("Clicking a scenario via tap coordinates (Flutter Canvas)...")
    box = page.viewport_size
    width = box['width']
    height = box['height']
    page.mouse.click(width * 0.9, height * 0.85)
    page.wait_for_timeout(5000)

    print("Taking simulation screenshot...")
    page.screenshot(path="/home/jules/verification/screenshots/verification_simulation.png")

    print("Clicking Play...")
    # The pause/play button is located in the bottom action bar on the far left.
    page.mouse.click(width * 0.32, height * 0.88)
    page.wait_for_timeout(8000) # Wait a few seconds to let animation occur

    print("Taking running screenshot...")
    page.screenshot(path="/home/jules/verification/screenshots/verification_running.png")

    page.wait_for_timeout(2000)

if __name__ == "__main__":
    os.makedirs("/home/jules/verification/screenshots", exist_ok=True)
    os.makedirs("/home/jules/verification/videos", exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            record_video_dir="/home/jules/verification/videos",
            viewport={'width': 1280, 'height': 720}
        )
        page = context.new_page()
        try:
            run_cuj(page)
        finally:
            context.close()
            browser.close()

    videos = glob.glob("/home/jules/verification/videos/*.webm")
    if videos:
        print(f"Recorded video at {videos[0]}")

# ⚠️ HOW TO RELOAD GAME FILES (VERY IMPORTANT!)

## Why You MUST Reload

The game code was modified in `res://player/player.gd`. Godot caches scripts in memory while running. If you just hit Play again without reloading, the **OLD CODE** will still be in memory!

That's why you need to **reload the files** before testing.

---

## Method 1: Simple Reload (RECOMMENDED)

### Step 1: Stop the Game
- Click the **Stop** button in Godot (or press Shift+F5)
- Make sure the game window is closed
- Wait for it to fully stop (check the Output console)

### Step 2: Reload the Scene
- In the **FileSystem** panel on the left
- Navigate to your main scene (usually `res://main.tscn` or similar)
- Right-click on the main scene file
- Select **"Reload Selected"** from the context menu

### Step 3: Run the Game
- Click **Play** (F5)
- Game should now have the new code loaded

---

## Method 2: Close and Reopen (ALTERNATIVE)

### Step 1: Close the Game Scene
- Close the currently open scene
- (You might get a save dialog - you don't need to save)

### Step 2: Reopen the Scene
- Open your main scene again
- This forces Godot to reload from disk

### Step 3: Run the Game
- Click **Play** (F5)

---

## Method 3: Restart Godot (NUCLEAR OPTION)

If the above don't work:

### Step 1: Close Godot Completely
- Save any unsaved work (if applicable)
- Close the Godot editor window completely
- Wait a moment

### Step 2: Reopen Godot
- Double-click the project folder or use `godot` command
- Godot will reload everything from disk

### Step 3: Run the Game
- Click **Play** (F5)

---

## How to Know if It Worked

### Signs the NEW Code Loaded ✅
When you run the game and reach 100% CPU by clicking at max:
```
[OVERHEAT] Click at 100% CPU! Added 5.0 heat. Total: 5.0/100
```

This message means the **new code IS running**. ✓

### Signs the OLD Code is Still Running ❌
If you see one of these messages, the old code is still in memory:
```
[OVERHEAT] Heating: timer=...  ← OLD CODE! Reload!
```

Or if overheat doesn't respond to clicks but instead waits 1+ seconds, reload again.

---

## Troubleshooting Reload Issues

### Problem: "Still seeing old behavior"
**Solution:**
1. Make absolutely sure the game is stopped
2. Wait 2 seconds
3. Try Method 3 (Restart Godot)

### Problem: "Console shows old messages"
**Solution:**
1. Click the **Clear Output** button in the Output console
2. Stop the game
3. Reload the scene
4. Run again
5. The console should now show new messages

### Problem: "Godot is being stubborn"
**Solution:**
1. Close Godot completely
2. Close any Godot processes (Task Manager)
3. Reopen Godot
4. Load the project fresh
5. Run the game

---

## Checklist Before Testing

- [ ] I stopped the running game (no play indicator)
- [ ] I reloaded the scene (Method 1, 2, or 3)
- [ ] I clicked Play to start fresh
- [ ] I see the game window start
- [ ] I'm about to test the overheat system

---

## Quick Reload Keyboard Shortcut

If you're in the Godot editor:
1. Make sure no game is running (stop button visible)
2. Right-click the scene in FileSystem
3. Click "Reload Selected"
4. Press F5 to play

---

## The Complete Test Cycle

```
1. Edit code ✓ (already done)
   ↓
2. STOP THE GAME (press Shift+F5 or click stop)
   ↓
3. RELOAD THE SCENE (right-click → Reload Selected)
   ↓
4. RUN THE GAME (press F5)
   ↓
5. TEST THE FIX (right-click at 100% CPU, watch console)
   ↓
6. CHECK CONSOLE (look for [OVERHEAT] messages)
   ↓
7. SUCCESS! ✓
```

---

## Console Output Location

If you're not sure where to see console messages:

**In Godot Editor:**
- Bottom of the screen: **Output** tab
- Make sure it's selected
- You should see game print() output there

**Game Output vs Script Errors:**
- Game messages: `print()` statements (black text)
- Errors: Show in red
- [OVERHEAT] messages should appear in black text

---

## Final Verification

Once you've reloaded and run the game:

### Right-click to 100% CPU
You should see:
```
CPU Generated! Current: 100 / 100
```

### Keep right-clicking at 100%
You should see:
```
[OVERHEAT] Click at 100% CPU! Added 5.0 heat. Total: 5.0/100
[OVERHEAT] Click at 100% CPU! Added 5.0 heat. Total: 10.0/100
[OVERHEAT] Click at 100% CPU! Added 5.0 heat. Total: 15.0/100
...
```

**If you see these messages = SUCCESS! ✅**
**The new code is running and the fix is working!**

---

## Don't Skip This!

If you skip reloading and just press Play again, you'll be running the OLD code with the OLD timer-based system. Then you'll report "it's not working" when actually you just needed to reload.

**So PLEASE:**
1. ✅ Stop the game
2. ✅ Reload the scene  
3. ✅ Run the game fresh
4. ✅ Then test

---

**Ready? Let's go!** 🚀

1. Stop the game (Shift+F5)
2. Reload the scene (FileSystem → right-click → Reload)
3. Run the game (F5)
4. Test the overheat system
5. Check the console output
6. Report your results!

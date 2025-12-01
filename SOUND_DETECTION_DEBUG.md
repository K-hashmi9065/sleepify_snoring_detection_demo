# Sound Detection Debug Guide

## Changes Made to Fix Sound Detection

### 1. **Lowered Sound Threshold**

- **Previous**: `soundThreshold = 20.0`
- **New**: `soundThreshold = 5.0`
- **Reason**: The previous threshold was too high, making it insensitive to normal sounds. The new threshold is more sensitive and will detect typical microphone input.

### 2. **Added Real-Time Amplitude Display**

- Now shows the current amplitude being detected in real-time
- Displays the threshold value for comparison
- Helps you understand if the microphone is working and what sound levels are being detected

### 3. **Enhanced Error Handling**

- Added error state tracking with `_errorMessage` field
- Errors now show in the UI with a red error box
- Added SnackBar notifications for errors
- Added `onError` handler to the microphone stream

### 4. **Better Visual Feedback**

- Blue info box shows current amplitude when listening
- Red error box shows any errors that occur
- Clear indication of microphone status

## Testing Steps

### Step 1: Check Permissions

1. Run the app on your device
2. When you navigate to the wave screen, it should ask for microphone permission
3. **IMPORTANT**: Make sure you grant the permission

### Step 2: Verify Microphone is Working

1. Look for the message: "Microphone is listening... Tap to stop"
2. Check the blue info box that shows:
   - Current Amplitude: [number]
   - Threshold: 5.0
3. Make some noise near your device and watch the amplitude value change

### Step 3: Debug Sound Detection

- **If amplitude is always 0.0**:
  - Microphone permission may not be granted
  - Check Android Settings → Apps → [Your App] → Permissions → Microphone
- **If amplitude changes but wave doesn't show**:

  - Check if amplitude exceeds 5.0
  - If amplitude is very low (< 5.0), you may need to make louder sounds

- **If you see an error message**:
  - Read the error in the red box or SnackBar
  - Common issues:
    - Permission denied
    - Microphone in use by another app
    - Device doesn't support the audio format

### Step 4: Adjust Threshold if Needed

If the threshold of 5.0 is too sensitive or not sensitive enough:

```dart
// In mesh_wave.dart, line 26-27
// Change this value:
static const double soundThreshold = 5.0; // Increase or decrease as needed
```

- **Increase** (e.g., 10.0, 15.0) if it detects too much background noise
- **Decrease** (e.g., 2.0, 3.0) if it's not sensitive enough

## Common Issues and Solutions

### Issue 1: Permission Not Granted

**Symptoms**: Error message about microphone permission
**Solution**:

1. Go to Phone Settings
2. Apps → [Your App Name]
3. Permissions → Microphone → Allow

### Issue 2: Amplitude Always Zero

**Symptoms**: Amplitude shows 0.00 even when making noise
**Solution**:

1. Ensure permission is granted
2. Test microphone with another app (voice recorder)
3. Restart the app
4. Check if another app is using the microphone

### Issue 3: Wave Shows Even Without Sound

**Symptoms**: Wave animation plays constantly
**Solution**: Increase the threshold value (see Step 4 above)

### Issue 4: Wave Never Shows

**Symptoms**: Amplitude changes but stays below threshold
**Solution**:

1. Make louder sounds
2. Move closer to the microphone
3. Decrease the threshold value

## Technical Details

### Audio Configuration

- **Sample Rate**: 16000 Hz
- **Channel**: Mono
- **Format**: PCM 16-bit
- **Processing**: Calculates average amplitude of audio samples

### Sound Level Calculation

```dart
// Converts raw audio bytes to amplitude
// Higher amplitude = louder sound
// Threshold determines when to show wave animation
```

## Next Steps

1. **Run the app** and navigate to the wave screen
2. **Grant microphone permission** when prompted
3. **Watch the amplitude display** - it should update in real-time
4. **Make sounds** (talk, clap, play music) and see if:
   - Amplitude increases
   - Wave animation appears when amplitude > 5.0
5. **Report back** with:
   - What amplitude values you're seeing
   - Whether sound detection is working
   - Any error messages displayed

import React, { useRef, useCallback, useMemo } from 'react';
import { TouchableOpacity, StyleSheet, useColorScheme, ViewStyle } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';

interface ProfileOptionsBottomSheetProps {
  bottomSheetRef: React.RefObject<BottomSheet>;
  onProfileSettings: () => void;
  onLogout: () => void;
}

const ProfileOptionsBottomSheet = ({
  bottomSheetRef,
  onProfileSettings,
  onLogout,
}: ProfileOptionsBottomSheetProps) => {
  const colorScheme = useColorScheme();
  const snapPoints = useMemo(() => ['25%'], []);

  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);

  return (
    <BottomSheet
      ref={bottomSheetRef}
      index={-1}
      snapPoints={snapPoints}
      onChange={handleSheetChanges}
      enablePanDownToClose
      backgroundStyle={{ backgroundColor: Colors[colorScheme ?? 'light'].background }}
      handleIndicatorStyle={{ backgroundColor: Colors[colorScheme ?? 'light'].underlineColor }}
    >
      <BottomSheetView style={styles.bottomSheetContent}>
        <TouchableOpacity 
          style={styles.bottomSheetOption}
          onPress={onProfileSettings}
        >
          <Ionicons
            name="person-circle-outline"
            size={24}
            color={Colors[colorScheme ?? 'light'].text}
          />
          <ThemedText style={styles.bottomSheetOptionText}>
            Profile Settings
          </ThemedText>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.bottomSheetOption}
          onPress={onLogout}
        >
          <Ionicons
            name="log-out-outline"
            size={24}
            color="#FF3B30"
          />
          <ThemedText style={styles.bottomSheetOptionTextDanger}>
            Logout
          </ThemedText>
        </TouchableOpacity>
      </BottomSheetView>
    </BottomSheet>
  );
};

const styles = StyleSheet.create({
  bottomSheetContent: {
    padding: 20,
  },
  bottomSheetOption: {
    flexDirection: 'row' as const,
    alignItems: 'center' as const,
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(150, 150, 150, 0.2)',
  },
  bottomSheetOptionText: {
    marginLeft: 15,
    fontSize: 16,
  },
  bottomSheetOptionTextDanger: {
    marginLeft: 15,
    fontSize: 16,
    color: '#FF3B30',
  },
});

export default ProfileOptionsBottomSheet; 
import React, { useState, useEffect } from 'react';
import { TouchableOpacity, StyleSheet, Text } from 'react-native';
import { ThemedText } from '@/components/ThemedText';

interface ProfileDescriptionProps {
  description?: string;
}

const ProfileDescription: React.FC<ProfileDescriptionProps> = ({ description }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [textTooLong, setTextTooLong] = useState(false);

  // Reset expanded state when description changes
  useEffect(() => {
    setIsExpanded(false);
  }, [description]);

  const handleTextLayout = (e: any) => {
    // Check if the text has been truncated by counting lines
    if (e.nativeEvent.lines && e.nativeEvent.lines.length > 2) {
      setTextTooLong(true);
    } else {
      setTextTooLong(false);
    }
  };

  const toggleExpand = () => {
    setIsExpanded(!isExpanded);
  };

  const styles = StyleSheet.create({
    bioContainer: {
      marginVertical: 4,
      width: '80%',
    },
    bio: {
      fontSize: 14,
      color: '#888',
      textAlign: 'left',
    }
  });

  return (
    <TouchableOpacity 
      style={styles.bioContainer}
      onPress={toggleExpand}
      activeOpacity={0.7}
    >
      <ThemedText 
        type="default" 
        style={styles.bio}
        numberOfLines={isExpanded ? undefined : 2}
        ellipsizeMode="tail"
        onTextLayout={handleTextLayout}
      >
        {description || ''}
      </ThemedText>
      
      {textTooLong && !isExpanded && (
        <Text style={{ color: '#888', fontSize: 12, marginTop: 2 }}>...</Text>
      )}
    </TouchableOpacity>
  );
};

export default ProfileDescription; 
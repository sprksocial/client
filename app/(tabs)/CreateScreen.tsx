import { SafeAreaView, StyleSheet, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import ContentWrapper from '@/components/global/ContentWrapper';
import { Colors } from '@/constants/Colors';

export default function CreateScreen() {
    const colorScheme = useColorScheme();

    const styles = StyleSheet.create({
      container: {
        backgroundColor: Colors[colorScheme ?? 'light'].background,
        height: '100%',
        alignContent: 'center',
        justifyContent: 'center',
      },
      scrollViewContent: {
        flexGrow: 1,
        paddingBottom: 20,
      },
    });
  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ThemedText type="title">CreateScreen</ThemedText>
        </ContentWrapper>
    </SafeAreaView>
  );
}

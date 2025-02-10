import { Text, type TextProps, StyleSheet } from 'react-native';

import { useThemeColor } from '@/hooks/useThemeColor';

export type ThemedTextProps = TextProps & {
  lightColor?: string;
  darkColor?: string;
  type?: 'default' | 'title' | 'defaultBold' | 'subtitle' | 'link' | 'name' | 'username' | 'comment' | 'description';
};

export function ThemedText({
  style,
  lightColor,
  darkColor,
  type = 'default',
  ...rest
}: ThemedTextProps) {
  const color = useThemeColor({ light: lightColor, dark: darkColor }, 'text');
  const fontFamily = 'Nunito';


const styles = StyleSheet.create({
  default: {
    fontSize: 18,
    lineHeight: 24,
  },
  defaultBold: {
    fontSize: 18,
    lineHeight: 24,
    fontWeight: 'bold',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    lineHeight: 32,
  },
  subtitle: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  link: {
    lineHeight: 30,
    fontSize: 16,
    color: '#0a7ea4',
  },
  name: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  username: {
    fontSize: 16,
    color: '#4f5155',
  },
  comment: {
    fontSize: 16,
  },
  description: {
    fontSize: 14,
    fontWeight: 'normal',
  },
});

  return (
    <Text
      style={[
        { color },
        type === 'default' ? styles.default : undefined,
        type === 'title' ? styles.title : undefined,
        type === 'defaultBold' ? styles.defaultBold : undefined,
        type === 'subtitle' ? styles.subtitle : undefined,
        type === 'description' ? styles.description : undefined,
        type === 'link' ? styles.link : undefined,
        type === 'name' ? styles.name : undefined,
        type === 'username' ? styles.username : undefined,
        type === 'comment' ? styles.comment : undefined,
        { fontFamily },
        style,
      ]}
      {...rest}
    />
  );
}

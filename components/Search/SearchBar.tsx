import { Colors } from "@/constants/Colors";
import React, { useState } from "react";
import { View, TextInput, StyleSheet, useColorScheme } from "react-native";

interface SearchBarProps {
  onSearch: (query: string) => void;
}

const SearchBar: React.FC<SearchBarProps> = ({ onSearch }) => {
  const [query, setQuery] = useState("");

  const handleSearch = () => {
    onSearch(query);
  };

  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      flexDirection: "row",
      alignItems: "center",
      borderWidth: 1,
      borderColor: Colors[colorScheme?? "light"].underlineColor,
      borderRadius: 10,
      padding: 5,
      marginHorizontal: 5,
      marginVertical: 10,
    },
    input: {
      flex: 1,
      padding: 10,
      fontSize: 16,
      fontFamily: "Nunito_400Regular",
    },
  });

  
  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholder="Search..."
        value={query}
        onChangeText={setQuery}
        returnKeyType="search"
        onSubmitEditing={handleSearch}
      />
    </View>
  );
};

export default SearchBar;
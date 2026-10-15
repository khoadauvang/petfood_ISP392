package com.isp392.petfood.controller;

import org.springframework.web.util.UriComponentsBuilder;

// Ghép bộ lọc hiện tại thành chuỗi query (đã mã hoá UTF-8) để link phân trang giữ nguyên bộ lọc.
// Ví dụ of("keyword", "mèo", "categoryId", 3, "species", null) -> "keyword=m%C3%A8o&categoryId=3"
final class QueryStrings {

    private QueryStrings() {
    }

    static String of(Object... nameValuePairs) {
        UriComponentsBuilder builder = UriComponentsBuilder.newInstance();
        for (int i = 0; i + 1 < nameValuePairs.length; i += 2) {
            Object value = nameValuePairs[i + 1];
            if (value != null && !value.toString().isBlank()) {
                builder.queryParam(String.valueOf(nameValuePairs[i]), value);
            }
        }
        String query = builder.build().encode().getQuery();
        return query == null ? "" : query;
    }
}

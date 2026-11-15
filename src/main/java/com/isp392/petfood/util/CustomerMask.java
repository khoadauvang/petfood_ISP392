package com.isp392.petfood.util;

// Che bớt thông tin khách khi hiện cho staff, cùng quy tắc với màn Báo cáo hội viên (JS maskCustomer* trong admin/dashboard.jsp):
//   Tên:   Phạm Quốc Dũng -> Phạm Q** Dũng;  Phạm Dũng -> Phạm D**;  Dũng -> D**
//   SĐT:   0912000004 -> 0912***004
//   Email: dung.pham@example.com -> d***m@example.com
public final class CustomerMask {

    private CustomerMask() {
    }

    public static String name(String name) {
        if (name == null || name.isBlank()) {
            return name;
        }
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].length() > 1 ? initial(parts[0]) + "**" : parts[0];
        }
        if (parts.length == 2) {
            return parts[0] + " " + initial(parts[1]) + "**";
        }
        StringBuilder sb = new StringBuilder(parts[0]);
        for (int i = 1; i < parts.length - 1; i++) {
            sb.append(' ').append(initial(parts[i])).append("**");
        }
        return sb.append(' ').append(parts[parts.length - 1]).toString();
    }

    public static String phone(String phone) {
        if (phone == null || phone.isBlank()) {
            return phone;
        }
        String clean = phone.trim().replaceAll("\\s+", "");
        if (clean.length() >= 7) {
            return clean.substring(0, 4) + "***" + clean.substring(clean.length() - 3);
        }
        if (clean.length() <= 4) {
            return clean.charAt(0) + "***";
        }
        return clean.substring(0, 2) + "***" + clean.substring(clean.length() - 2);
    }

    public static String email(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        String trimmed = email.trim();
        int at = trimmed.lastIndexOf('@');
        String local = trimmed.substring(0, at);
        String domain = trimmed.substring(at + 1);
        if (local.length() <= 1) {
            return local + "***@" + domain;
        }
        return local.charAt(0) + "***" + local.charAt(local.length() - 1) + "@" + domain;
    }

    // Chữ cái đầu, giữ nguyên ký tự có dấu ghép (code point)
    private static String initial(String word) {
        return new String(Character.toChars(word.codePointAt(0)));
    }
}

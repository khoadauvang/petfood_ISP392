package com.isp392.petfood.entity;

import com.isp392.petfood.enums.MediaType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Ảnh / video khách gửi kèm yêu cầu trả hàng, 1 đến 5 file mỗi yêu cầu (BR-33, BE kiểm tra)
@Entity
@Table(name = "ReturnMedia")
@Getter
@Setter
@NoArgsConstructor
public class ReturnMedia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "media_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "return_id", nullable = false)
    private ReturnRequest returnRequest;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_type", nullable = false, length = 10)
    private MediaType mediaType;

    @Column(name = "media_url", nullable = false, length = 255)
    private String mediaUrl;

    public ReturnMedia(ReturnRequest returnRequest, MediaType mediaType, String mediaUrl) {
        this.returnRequest = returnRequest;
        this.mediaType = mediaType;
        this.mediaUrl = mediaUrl;
    }
}

## TR

SecureBase kütüphanesi standart base64 algoritmasına ek olarak gizli anahtar seçeneği sunmaktadır. Böylelikle kütüphaneyi kullanan projelere özgü base64 işlemi gerçekleşir. Her projenin gizli anahtarı farklı olacağından oluşan base64 çıktısıda gizli anahtara bağlı olarak değişir.

Detaylı bilgi için aşağıdaki kaynağı inceleyiniz.

[SecureBase Wiki](https://beytullahakyuz.gitbook.io/securebase)

## Kullanım/Örnek

```delphi
var sb: TSecureBase;
var encoding: TSBEncoding;
var res: string;

encoding := TSBEncoding.UTF8;
sb := TSecureBase.Create(encoding);
sb.SetSecretKey(secretkey);

//encoding
res := sb.Encode("plain text data");

//decoding
try
	res := sb.Decode("encoded data");
except on ex: Exception do
	Application.MessageBox(PChar('invalid decoding!'), PChar('!!'), MB_ICONINFORMATION + MB_OK);
end;
```

## Ekran Görüntüleri

Kodlama (Farklı gizli anahtarlarla)

![Kodlama](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_1.png)
![Kodlama](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_2.png)

Kod çözme

![Kod çözme](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_1_decoding.png)
![Kod çözme](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_2_decoding.png)


## EN

The SecureBase library offers a secret key option in addition to the standard base64 algorithm. Since the secret key will be different in each project, the base64 output will also vary depending on the secret key.

For detailed information, please review the source below.

[SecureBase Wiki](https://beytullahakyuz.gitbook.io/securebase)

## Using/Example

```delphi
var sb: TSecureBase;
var encoding: TSBEncoding;
var res: string;

encoding := TSBEncoding.UTF8;
sb := TSecureBase.Create(encoding);
sb.SetSecretKey(secretkey);

//encoding
res := sb.Encode("plain text data");

//decoding
try
	res := sb.Decode("encoded data");
except on ex: Exception do
	Application.MessageBox(PChar('invalid decoding!'), PChar('!!'), MB_ICONINFORMATION + MB_OK);
end;
```

## Screenshots

Encoding (Different secret keys)

![Encoding](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_1.png)
![Encoding](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_2.png)

Decoding

![Decoding](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_1_decoding.png)
![Decoding](https://github.com/beytullahakyuz/securebase-delphi/blob/main/screenshots/en_2_decoding.png)

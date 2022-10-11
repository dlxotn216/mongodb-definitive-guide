# MongoDB 완벽가이드

## 기본개념

* 데이터의 기본 단위는 도큐먼트
* 컬렉션은 동적 스키마가 있는 테이블과 동일한 개념
* 단일 인스턴스는 여러개의 독립적인 데이터베이스를 호스팅
* 몽고 셸을 통해 조작 가능
    * 여기에선 Datagrip을 활용 함

## Document

* 정렬된 키와 연결된 값의 집합으로 이뤄짐

```mongodb-json-query
{
  "greeting": "Hello world!"
}
```

* 데이터 타입과 대소문자 구별

아래는 서로 다른 도큐먼트임

```mongodb-json-query
{
  "count": 5
}
{
  "count": "5"
}
```

## 컬렉션

* 도큐먼트의 모음
* 하나의 컬렉션 내에 서로 다른 구조의 도큐먼트를 가질 수 있음
    * 그래도 용도에 따라 적절히 컬렉션을 나누는것이 좋다

### 컬렉션 네이밍

* 널 스트링, 빈 문자열은 사용 불가
* system.으로 시작하는 컬렉션 이름은 예약어
* 사용자가 만든 컬렉션은 $ 예약어 사용 불가

### 서브 컬렉션

* .을 통해서 컬렉션을 체계화 함
* 단지 이름을 기반으로 체계화 하는 것이지 상하 관계가 성립하는것은 아님
* ex)
    * master.items
    * master.categories
    * master.admins

### 데이터베이스

* 컬렉션의 그룹
* 컬렉션과 마찬가지로 이름으로 식별 됨
* 최대 64 bytes
* 시맨틱을 갖는 예약된 데이터베이스
    * admin
        * 인증과 권한 부여를 담당
    * local
        * 단일 서버에 대한 데이터 저장
        * 레플리카 셋ㅅ에서 local 데이터베이스는 복제되지 않음
    * config
        * 샤딩 된 클러스터의 경우 config db를 통해 샤드에 분배 함
* ex)
    * cms 데이터베이스의 blog.posts 컬렉션은 cms.blog.posts로 나타 냄
    * 네임스페이스(cms.blog.posts)의 최대 길이는 120 bytes 이나 실제 100 bytes 이하이어야 함

## 기본 데이터 조작

* db 변수는 현재 데이터베이스를 가리킨다
* use <db>로 선택 가능하다

```mongodb-json-query
use demo
```

### 생성

* insertOne

단건 삽입

```mongodb-json-query
// 지역 변수
movie = {
  "title": "Star wars",
  "director": "Geroge Lucas",
  "year": 1977,
}
db.movies.insertOne(movie)

// 확인
db.movies.find()
```

ObjectId가 자동 발급 됨  
![img.png](img.png)

### 읽기

* findOne

단건 조회

```mongodb-json-query
db.movies.findOne()
```

### 갱신

* updateOne

단건 갱신

첫번째 인자로 매칭하는 조건 명시, 두번째로 갱신 작업에 대한 기술
```mongodb-json-query
db.movies.updateOne({
  title: 'Star wars'
},
{$set: {reviews: []
}
});
```
updateOne이라 하나만 업데이트 됐음

![img_1.png](img_1.png)

### 삭제

* deleteOne
* deleteMany

![img_2.png](img_2.png)

## 데이터 형
* null
* Boolean
* 숫자
  * 셸에선 64비트 부동소수점을 기본으로 함
  * 4byte, 8byte 정수는 NumberInt, NumberLong을 사용해야 함
  * NumberInt(4), NumberLong(12)
* 문자열
  * UTF8
* 날짜
  * Date로 표현
  * new Date()로 생성해야 함
  * 타임존은 저장하지 않음
* 정규표현식
  * 자바스크립트 정규표현식 문법
* 배열
* 내장 도큐먼트
* 객체 ID
  * 12byte
  * 하나의 컬렉션에서 도큐먼튼는 고유한 아이디를 가짐
  * 분산 데이터베이스를 위해 자동증가 값이 아닌 ObjectId를 사용 함
  * 0 1 2 3 4 5 6 7 8 9 10 11
  * 0~2는 타임스탬프, 3~8은 랜덤, 9~11은 카운타
* 이진데이터
* 자바스크립트 코드

## 도큐먼트 생성, 갱신, 삭제
### insertMany 
```mongodb-json-query
db.movies.insertMany(
    [
        {'title': 'GhostBusters'},
        {'title': 'E.T'},
        {'title': 'Blade Runner'}
    ]
)
```
* 다량의 도큐먼트 생성시 반복보다 훨씬 효율적임
* 데이터 피드
* RDB와 같은 원본 소스에서 임포트하는 경우 mongoimport 도구가 있음
* 48메가 이상이면 드라이버가 여러 insertMany 구문으로 분리 함

```mongodb-json-query
db.movies.insertMany(
    [
        {_id: 0, 'title': 'GhostBusters'},
        {_id: 1, 'title': 'E.T'},
        {_id: 1, 'title': 'Blade Runner'},
        {_id: 2, 'title': 'Blade Runner'}
    ],
    {
        ordered: true
    }
)
```
* 기본으로 ordered가 true임
* 정렬된 삽입이면 오류가 발생하는 지점에서 중단 함
* 비정렬된 삽입이면 오류 발생 여부에 상관없이 모두 삽입 시도 함

### deleteOne
* 필터와 일치하는 첫번째 도큐먼트를 삭제
```mongodb-json-query
db.movies.deleteOne({
    _id: 4
})
```
![img_3.png](img_3.png)

### deleteMany
* 필터와 일치하는 모든 도큐먼트를 삭제
```mongodb-json-query
db.movies.deleteMany({
    title: 'Blade Runner'
})
```
![img_4.png](img_4.png)
* 이전버전에서 remove를 지원하나 deleteOne, deleteMany를 쓸 것

### drop
* deleteMany에 아무런 인수를 주지 않으면 모든 도큐먼트가 제거 됨
* drop이 더 빠름

### replaceOne
* 도큐먼트를 새로운것으로 완전 치환
* 대대적인 스키마 마이그레이션에 유용 함 
```mongodb-json-query
db.users.insertOne({
    name: 'lee',
    friends: 32,
    enemies: 2
});

var lee = db.users.findOne({name: 'lee'});
lee.username = lee.name;
delete lee.name;  // name -> username

// relationships이라는 내장도큐먼트로 이동
lee.relationships = {
    friends: lee.friends,
    enemies: lee.enemies,
};
delete lee.friends;
delete lee.enemies;
db.users.replaceOne({name: 'lee'}, lee);
```
![img_5.png](img_5.png)

* 주어진 조건절에 두 개 이상의 도큐먼트가 매치하면 하나만 치환 한
  * 단 주의할 것이 id가 중복되는 상태가 발생할 수 있다는 것
```mongodb-json-query
db.users.insertOne({
    name: 'lee',
    friends: 32,
    enemies: 2
});
db.users.insertOne({
    name: 'lee',
    friends: 22,
    enemies: 2
});
var lee = db.users.findOne({name: 'lee', friends: 22}) // 63452da64b62ab4f8db6887a를 조회 했으나
lee.friends++;
db.users.replaceOne({name: 'lee'}, lee); // 63452d914b62ab4f8db68878가 대체 되도록 시도 됨
```
![img_6.png](img_6.png)

### 갱신연산자
* 도큐먼트의 특정 부분만 갱신하는 경우 원자적 갱신 연산자를 쓸 수 있음

#### set/unset 제한자(modifier)
**set**
* 필드 값을 설정
* 없으면 필드를 추가 함
```mongodb-json-query
db.users.updateOne({name: 'lee'}, {
    $set: {
        'favorite book': 'harry porter'
    }
})

// 데이터 형도 바꿀 수 있음
db.users.updateOne({name: 'lee'}, {
    $set: {
        'favorite book': ['harry porter', 'effective kotlin']
    }
})
```
* replaceOne과 무슨 차이일까?
  * replaceOne은 아예 도큐먼트를 대치하는 것이니 변경내역 소실 가능성이 있음
  * 조회 후 replace이니까
  * set은 atomic 하므로 소실 가능성이 없다고 봐도 좋을 듯

**unset** 
* 키와 값 제거
```mongodb-json-query
db.users.updateOne({name: 'lee'}, {
    $unset: {
        'favorite book': ''
    }
})
```
* 내장 도큐먼트도 수정 가능
```mongodb-json-query
db.users.insertOne({
    name: 'lee2',
    friends: 22,
    enemies: 1,
    additional: {
        hobby: ['running', 'ps'],
        address: 'home'
    }
})
;
db.users.updateOne({name: 'lee2'},{
    $set: {
        'additional.address': 'changed'
    }
})
```

#### inc 제한자(modifier)
* 이미 존재하는 키를 변경하거나 추가
* set과 유사하나 숫자의 증감을 위해 설계 됨
* int, long, double, decimal에 사용 가능
```mongodb-json-query
db.analytics.insertOne({
    url: 'www.taesu.com',
    pageviews: 42
});
db.analytics.updateOne({'url': 'www.taesu.com'},
    {
        $inc: {'pageviews': 1}
    }
);
```

### 배열 연산자
#### push
* 배열이 없으면 생성 후 추가 함
```mongodb-json-query
db.blog.posts.insertOne({
    title: 'A post',
    content: '...'
});
db.blog.posts.updateOne({title: 'A post'},{
    $push: {
        comments: {
            name: 'lee taesu',
            content: 'nice!'
        }
    }
});
// 여러개 삽입
db.blog.posts.updateOne({title: 'A post'}, {
    $push: {
        comments: [
            {
                name: 'lee taesu',
                content: 'nice!'
            },
            {
                name: 'lee taesu',
                content: 'nice!'
            }
        ]
    }
});

// each로도 가능
db.blog.posts.updateOne({title: 'A post'}, {
    $push: {
        comments: {
            $each: [
                {
                    name: 'lee taesu',
                    content: 'nice 0!'
                },
                {
                    name: 'lee taesu',
                    content: 'nice 1!'
                }
            ]
        }
    }
})
```

#### push + slice
* push와 slice로 길이 유지가 가능
* Top-N 기능 구현
* 도큐먼트 내에 큐도 구현 가능
* slice, sort를 push랑 쓰려면 반드시 each를 써야 함
```mongodb-json-query
db.blog.posts.updateOne({title: 'A post'}, {
    $push: {
        comments: {
            $each: [
                {
                    name: 'lee taesu',
                    content: 'nice 123'
                },
                {
                    name: 'lee taesu',
                    content: 'nice 456'
                }
            ],
            $slice: -2
        }
    }
})
```
* nice0!, nice1! 댓글은 밀리고 새로 추가 된 두개만 남음
![img_7.png](img_7.png)

* sort로 정렬도 가능
```mongodb-json-query
db.blog.posts.updateOne({title: 'A post'}, {
    $push: {
        comments: {
            $each: [
                {
                    name: 'lee taesu',
                    content: 'nice 123'
                },
                {
                    name: 'lee taesu',
                    content: 'nice 456'
                }
            ],
            $slice: -2,
            $sort: {'content': -1}
        }
    }
})
```

### 배열을 집합으로
#### ne
```mongodb-json-query
db.papers.insertOne({author: 'taesu'});
db.papers.updateOne({author: {$ne: 'taesu'}}, {$push: {author: 'taesu'}}); // not updated
db.papers.find()
```

#### addToSet
* 고유한 값 추가해야 하는 경우 addToSet, each를 조합
```mongodb-json-query
db.users.insertOne({
    name: 'lee',
    emails: [
        'taesu@gmail.com',
        'taesu@gmail.com'
    ]
});

db.users.updateOne({name: 'lee'}, {
    $addToSet: {
        emails: {
            $each: [
                'taesulee93@gmail.com'
            ]
        }
    }
});
```

* 주의, 이렇게 해버리면 이중배열이 들어간다는 것
```mongodb-json-query
db.users.updateOne({name: 'lee'}, {
    $addToSet: {
        emails: [
            'taesulee93@gmail.com'
        ]
    }
});
```

### 요소 제거
#### pop
```mongodb-json-query
// 배열의 처음부터 제거
db.users.updateOne({}, {$pop: {emails: -1}});
// 배열의 마지막부터 제거
db.users.updateOne({}, {$pop: {emails: 1}});
```
#### pull
* 하나의 도큐먼트의 emails 배열에서 일치하는 요소 제거
* 조건에 부합하는 도큐먼트가 여러개일때 하나가 적용되면 나머지는 무시 됨 (updateOne)
  * doc1: {emails: '...'}, doc2: {emails: '...'} 일때 doc1만 계속 배열이 지워질거임
```mongodb-json-query
db.users.updateOne({}, {$pull: {emails: 'taesu@gmail.com'}})
```
* 여러 도큐먼트에 적용하고 싶다면
```mongodb-json-query
db.users.updateMany({}, {$pull: {emails: 'taesu@gmail.com'}})
```


### 배열의 위치기반 변경
* 몇번째 요소인지 모르는 경우 'comments.$.name' 으로 접근 가능하다
```mongodb-json-query
db.blog.posts.insertOne({
    title: 'A post',
    content: '...',
    comments: [{
        name: 'lee taesu',
        content: 'nice!2awef'
    }]
});

db.blog.posts.updateMany({'comments.name': 'lee taesu'}, {
    $set: {
        'comments.$.name': 'Lee Tae Su'
    }
})
```
* arrayFilters를 통해서 조건에 맞는 배열만 변경 가능
```mongodb-json-query
// 투표 수가 -5 이하인 댓글은 숨김 처리
db.blog.posts.updateMany(
    {'comments.name': 'lee taesu'},
    {
        $set: {'comments.$[element].visible': false}  // 각 요소를 element로 선언
    },
    {
        arrayFilters: [{'element.votes': {$lte: -5}}]   // 여기서 사용
    }
)
```

### Upsert
* 1에 넘긴 인자에 매치하는 도큐먼트 검색
* 2에 넘긴 오퍼레이션 수행
* 3에 upsert: true라면 없으면 생성하고 오퍼레이션 수행
* 애플리케이션 로직으로 upsert를 구현하면 경쟁상태에 빠질 수 있음
  * UK 등으로 정합성은 보장할 수 있으나 오류가 날 것임
  * Upsert는 원자적이므로 비교적 안전
```mongodb-json-query
db.analytics.updateOne(
    {url: 'www.taesu2.com',},
    {$inc: {pageviews: 1}},
    {upsert: true}
    )
```

* 주의, 아래처럼 하면 pageviews: 0인 도큐먼트는 항상 없을 것이므로 매번 도큐먼트가 생성된다
```mongodb-json-query
db.analytics.updateOne({url: 'www.taesu2.com', pageviews: 0},
    {$inc: {pageviews: 1}},
    {upsert: true}
    )
```
* 도큐먼트 생성과 동시에 필드 설정이 필요하다면 $setOnInsert를 사용할 것
```mongodb-json-query
db.analytics.updateOne({url: 'www.taesu3.com',},
    {
        $inc: {pageviews: 1},
        $setOnInsert: {findBy: 'taesu'}
    },
    {upsert: true}
)
```

### updateMany
* updateOne과 매개변수는 동일
* updateOne은 필터에 부합하는 첫번째 도큐먼트만 갱신
* 필터에 부합하는 모든 도큐먼트 갱신은 updateMany
* 스키마 변경, 특정 사용자에 새로운 정보 추가 등에 효율적임 
```mongodb-json-query
db.users.insertMany(
    [
        {name: 'lee', birth: '1993-02-16'},
        {name: 'lee2', birth: '1991-02-16'},
    ]
);
db.users.updateMany({birth: '1993-02-16'}, {
    $set: {gift: 'happy birthday pack'}
})
```

### findAndGet (수정한 도큐먼트 반환)
**findOneAndUpdate**
* set and get을 원자적으로 해야하는 작업에 적합
* 여러 프로세스 중 락 등이 필요한 경우 아래처럼 
  * type에 따라 ready 상태인 것을 프로세스 1이 획득 하면서 ongoing으로 변경
  * 변경 됐다면 return 된것이 있음
  * 아무것도 없다면 작업 진행하지 않음
```mongodb-json-query
db.jobs.findOneAndUpdate(
    {type: 'MY_BATCH', status: 'READY'},
    {
        $set: {status: 'ONGOING'},
    },
    {
        returnNewDocument: true
    }
    )
        
// 작업 다한 프로세스는 완료처리로
db.jobs.updateOne({type: 'MY_BATCH', status: 'ONGOING'}, {
    $set: {status: 'READY'}
})
```

**findOneAndReplace**
* returnNewDocument가 false면 교체 전 도큐먼트
* returnNewDocument가 true면 교체 후 도큐먼트
```mongodb-json-query
db.types.drop()
db.types.find()
db.types.insertOne({name: 'type1', when: '111'});
var type = db.types.findOne({name: 'type1'})
type.when = '123213'
db.types.findOneAndReplace({name: 'type1'}, type,
{
    returnNewDocument: true
})
```

**findOneAndDelete**
* 삭제된 도큐먼트를 반환

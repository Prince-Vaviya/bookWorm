import '../models/book.dart';

final List<Book> mockBooksCatalog = [
  Book(
    id: 'book-1',
    title: 'Designing Data-Intensive Applications',
    author: 'Martin Kleppmann',
    authorBio:
        'Researcher in distributed systems and security at the University of Cambridge and author of influential software architecture books.',
    coverUrl:
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=800&auto=format&fit=crop',
    rating: 4.9,
    reviewCount: 1420,
    totalPages: 616,
    currentPage: 246,
    genre: 'Technology',
    tags: ['Architecture', 'Distributed Systems', 'Databases', 'Reliability'],
    synopsis:
        'Data is at the center of many challenges in system design today. Difficult issues need to be figured out, such as scalability, consistency, reliability, efficiency, and maintainability. This book helps software engineers navigate the diverse and fast-changing landscape of technologies for processing and storing data.',
    keyQuote:
        '"Reliability means making systems work correctly, even when things go wrong. Faults cannot be prevented entirely, so fault-tolerance mechanisms are needed."',
    publishedYear: '2017',
    isbn: '978-1449373320',
    shelfStatus: ShelfStatus.currentlyReading,
    isFavorite: true,
    lastReadAt: DateTime.now().subtract(const Duration(hours: 2)),
    chapters: [
      Chapter(
        number: 1,
        title: 'Reliable, Scalable, and Maintainable Applications',
        estimatedMinutes: 28,
        content: '''
Today, many applications are data-intensive, as opposed to compute-intensive. Raw CPU power is rarely a limiting factor for these systems—bigger problems are usually the amount of data, the complexity of data, and the speed at which it is changing.

A data-intensive application is typically built from standard building blocks:
• Databases: store data so that they, or another application, can find it again later.
• Caches: remember the result of an expensive operation to speed up reads.
• Search indexes: allow users to search data by keyword or filter it in various ways.
• Stream processing: send a message to another process, handled asynchronously.
• Batch processing: periodically crunch a large amount of accumulated data.

Thinking About Systems
When software is described as reliable, scalable, and maintainable, what does that really mean?

Reliability
The system should continue to work correctly (performing the correct function at the desired level of performance) even in the face of adversity (hardware or software faults, and even human error).

Scalability
As the system grows (in data volume, traffic volume, or complexity), there should be reasonable ways of dealing with that growth.
''',
      ),
      Chapter(
        number: 2,
        title: 'Data Models and Query Languages',
        estimatedMinutes: 34,
        content: '''
Data models are perhaps the most important part of developing software, because they have such a profound effect: not only on how the software is written, but also on how we think about the problem that we are solving.

Relational Model Versus Document Model
The best-known data model today is probably that of SQL, proposed by Edgar Codd in 1970. The relational model represents data as relations (called tables in SQL), where each relation is an unordered collection of tuples (rows in SQL).

The NoSQL movement sought to address specific limitations of relational databases:
1. A need for greater scalability than relational databases can easily achieve.
2. A widespread preference for free and open source software over commercial products.
3. Specialized query operations that are not well supported by the relational model.
4. Frustration with the restrictiveness of relational schemas and a desire for more dynamic data models.
''',
      ),
      Chapter(
        number: 3,
        title: 'Storage and Retrieval: Under the Hood',
        estimatedMinutes: 40,
        content: '''
On the most fundamental level, a database needs to do two things: when you give it some data, it must store the data; and when you ask it for the data later, it must give the data back to you.

Consider the world's simplest database, implemented as two Bash functions:
db_set () {
    echo "\$1,\$2" >> database
}
db_get () {
    grep "^\$1," database | sed -e "s/^\$1,//" | tail -n 1
}

The underlying storage format is a simple log—an append-only sequence of records. Every call to db_set appends to the end of the file. To look up a key, db_get scans the file from beginning to end, looking for the last occurrence of the key.
''',
      ),
    ],
    reviews: [
      Review(
        id: 'rev-1',
        reviewerName: 'Alex Rivera',
        rating: 5.0,
        date: '3 days ago',
        comment:
            'A masterclass in systems thinking. Martin deconstructs consensus, replication, and partitioning with unmatched clarity.',
        likesCount: 38,
      ),
      Review(
        id: 'rev-2',
        reviewerName: 'Sarah Chen',
        rating: 5.0,
        date: '1 week ago',
        comment:
            'Mandatory reading for every senior engineer. The chapters on batch vs streaming gave me an entirely new vocabulary.',
        likesCount: 24,
      ),
    ],
  ),
  Book(
    id: 'book-2',
    title: 'Meditations',
    author: 'Marcus Aurelius',
    authorBio:
        'Roman emperor from 161 to 180 AD and a Stoic philosopher. His personal private journals became one of history’s greatest reflections on duty and discipline.',
    coverUrl:
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=800&auto=format&fit=crop',
    rating: 4.8,
    reviewCount: 3250,
    totalPages: 254,
    currentPage: 120,
    genre: 'Philosophy',
    tags: ['Stoicism', 'Mindset', 'Ancient Wisdom', 'Classics'],
    synopsis:
        'Written in Greek without any intention of publication, the Meditations of Marcus Aurelius offer a remarkable series of challenging spiritual reflections and exercises developed as the emperor struggled to understand himself and make sense of the universe.',
    keyQuote:
        '"You have power over your mind - not outside events. Realize this, and you will find strength."',
    publishedYear: '180 AD',
    isbn: '978-0140449334',
    shelfStatus: ShelfStatus.currentlyReading,
    isFavorite: true,
    lastReadAt: DateTime.now().subtract(const Duration(days: 1)),
    chapters: [
      Chapter(
        number: 1,
        title: 'Book I: Debts and Lessons',
        estimatedMinutes: 20,
        content: '''
From my grandfather Verus: character and self-control.
From my mother: piety and generosity; abstinence not only from doing evil, but also from the very thought of doing it; and further, simplicity in my way of living, far removed from the habits of the rich.

From Apollonius: moral freedom and unswerving purpose; to look to nothing else, not even for a moment, except to reason; and always to be the same, in sharp pains, in the loss of a child, and in long illnesses.

From Rusticus: to realize that my character required improvement and discipline; and not to be led astray into enthusiams for rhetoric or composing treatises on abstract principles.
''',
      ),
      Chapter(
        number: 2,
        title: 'Book II: On the River Gran',
        estimatedMinutes: 18,
        content: '''
When you wake up in the morning, tell yourself: The people I deal with today will be meddling, ungrateful, arrogant, dishonest, jealous, and surly. They are like this because they cannot distinguish good from evil.

But I have seen the beauty of good, and the ugliness of evil, and have recognized that the wrongdoer has a nature related to my own—not of the same blood or birth, but the same mind, and possessing a share of the divine. And so none of them can hurt me.
''',
      ),
    ],
    reviews: [
      Review(
        id: 'rev-3',
        reviewerName: 'Marcus Thorne',
        rating: 5.0,
        date: '2 weeks ago',
        comment:
            'Re-reading this every year grounds my daily priorities. The translation by Gregory Hays is poetic and razor-sharp.',
        likesCount: 52,
      ),
    ],
  ),
  Book(
    id: 'book-3',
    title: 'Atomic Habits',
    author: 'James Clear',
    authorBio:
        'Writer and speaker focused on habits, decision making, and continuous improvement. His newsletter reaches over 3 million subscribers.',
    coverUrl:
        'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?q=80&w=800&auto=format&fit=crop',
    rating: 4.9,
    reviewCount: 8900,
    totalPages: 320,
    currentPage: 320,
    genre: 'Self Development',
    tags: ['Habits', 'Productivity', 'Psychology', 'Personal Growth'],
    synopsis:
        'No matter your goals, Atomic Habits offers a proven framework for improving--every day. James Clear reveals practical strategies that will teach you exactly how to form good habits, break bad ones, and master the tiny behaviors that lead to remarkable results.',
    keyQuote:
        '"You do not rise to the level of your goals. You fall to the level of your systems."',
    publishedYear: '2018',
    isbn: '978-0735211292',
    shelfStatus: ShelfStatus.completed,
    isFavorite: true,
    lastReadAt: DateTime.now().subtract(const Duration(days: 12)),
    chapters: [
      Chapter(
        number: 1,
        title: 'The Surprising Power of Atomic Habits',
        estimatedMinutes: 22,
        content: '''
The fate of British Cycling changed one day in 2003. The organization, which was the governing body for professional cycling in Great Britain, had recently hired Dave Brailsford as its new performance director.

At the time, professional cyclists in Great Britain had endured nearly one hundred years of mediocrity. Since 1907, British riders had won just a single gold medal at the Olympic Games.

Brailsford had been hired to put British Cycling on a new trajectory. What made him different from previous coaches was his relentless commitment to a strategy that he referred to as "the aggregation of marginal gains."
''',
      ),
    ],
    reviews: [
      Review(
        id: 'rev-4',
        reviewerName: 'Elena Rostova',
        rating: 5.0,
        date: '1 month ago',
        comment:
            'The 1% rule fundamentally changed my approach to building reading streaks. Highly actionable!',
        likesCount: 77,
      ),
    ],
  ),
  Book(
    id: 'book-4',
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    authorBio:
        'Nobel Memorial Prize laureate in Economic Sciences and professor of psychology at Princeton University.',
    coverUrl:
        'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=800&auto=format&fit=crop',
    rating: 4.7,
    reviewCount: 4600,
    totalPages: 499,
    currentPage: 0,
    genre: 'Psychology',
    tags: ['Cognitive Science', 'Behavioral Economics', 'Decision Making'],
    synopsis:
        'Daniel Kahneman takes us on a groundbreaking tour of the mind and explains the two systems that drive the way we think: System 1 is fast, intuitive, and emotional; System 2 is slower, more deliberative, and more logical.',
    keyQuote:
        '"A reliable way to make people believe in falsehoods is frequent repetition, because familiarity is not easily distinguished from truth."',
    publishedYear: '2011',
    isbn: '978-0374533557',
    shelfStatus: ShelfStatus.wantToRead,
    isFavorite: false,
    chapters: [
      Chapter(
        number: 1,
        title: 'Two Systems',
        estimatedMinutes: 25,
        content: '''
To observe your mind in automatic mode, glance at the image of the woman’s face on the next page. You experienced something called System 1: you knew at a glance that the young woman has dark hair, is threatening, and is about to shout.

Now look at the following problem: 17 × 24.
You knew immediately that this is a multiplication problem, and probably knew that you could solve it with paper and pencil. You also had some vague intuitive knowledge of the range of possible results. But you did not know the exact answer without conscious deliberation. That was System 2.
''',
      ),
    ],
    reviews: [],
  ),
  Book(
    id: 'book-5',
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    authorBio:
        'Historian, philosopher, and the bestselling author of Sapiens, Homo Deus, and 21 Lessons for the 21st Century.',
    coverUrl:
        'https://images.unsplash.com/photo-1461360370896-922624d12aa1?q=80&w=800&auto=format&fit=crop',
    rating: 4.8,
    reviewCount: 6800,
    totalPages: 443,
    currentPage: 0,
    genre: 'History',
    tags: ['Anthropology', 'Evolution', 'Civilization', 'History'],
    synopsis:
        'One hundred thousand years ago, at least six different species of humans inhabited Earth. Yet today there is only one—Homo sapiens. How did our species succeed in the battle for dominance? Why did our foraging ancestors come together to create cities and kingdoms?',
    keyQuote:
        '"You could never convince a monkey to give you a banana by promising him limitless bananas after death in monkey heaven."',
    publishedYear: '2014',
    isbn: '978-0062316097',
    shelfStatus: ShelfStatus.wantToRead,
    isFavorite: false,
    chapters: [
      Chapter(
        number: 1,
        title: 'An Animal of No Significance',
        estimatedMinutes: 24,
        content: '''
About 13.5 billion years ago, matter, energy, time and space came into being in what is known as the Big Bang. The story of these fundamental features of our universe is called physics.

About 300,000 years after their appearance, matter and energy started to coalesce into complex structures, called atoms, which then combined into molecules. The story of atoms, molecules and their interactions is called chemistry.

About 3.8 billion years ago, on a planet called Earth, certain molecules combined to form particularly large and intricate structures called organisms. The story of organisms is called biology.
''',
      ),
    ],
    reviews: [],
  ),
  Book(
    id: 'book-6',
    title: 'Klara and the Sun',
    author: 'Kazuo Ishiguro',
    authorBio:
        'Nobel Prize-winning British novelist, screenwriter, and short-story writer known for The Remains of the Day and Never Let Me Go.',
    coverUrl:
        'https://images.unsplash.com/photo-1532012164546-f432f2e3edd4?q=80&w=800&auto=format&fit=crop',
    rating: 4.6,
    reviewCount: 2100,
    totalPages: 303,
    currentPage: 303,
    genre: 'Fiction',
    tags: ['Sci-Fi', 'AI', 'Literary Fiction', 'Nobel Laureate'],
    synopsis:
        'The story of Klara, an Artificial Friend with outstanding observational qualities, who, from her place in the store, watches carefully the behavior of those who come in to browse, and of those who pass on the street outside. She remains hopeful that a customer will soon choose her.',
    keyQuote:
        '"Do you believe in the human heart? I do not mean simply the organ, obviously. But do you think there is something that makes each of us special and individual?"',
    publishedYear: '2021',
    isbn: '978-0593318171',
    shelfStatus: ShelfStatus.completed,
    isFavorite: false,
    lastReadAt: DateTime.now().subtract(const Duration(days: 20)),
    chapters: [
      Chapter(
        number: 1,
        title: 'Part One',
        estimatedMinutes: 30,
        content: '''
When we were new, Rosa and I were mid-store, on the magazine table side, and could see through more than half of the window. So we could see the outside quite well—the office workers hurrying by, the taxis, the runners, the tourists, the Beggar Man and his dog across the street.

Once we were more settled, Manager allowed us to walk up to the front glass itself, provided we stepped back smoothly if any customer entered.
''',
      ),
    ],
    reviews: [],
  ),
];

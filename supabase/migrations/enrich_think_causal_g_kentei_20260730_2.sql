BEGIN;

UPDATE public.questions SET explanation_data = explanation_data || '{"think": "カギは『勢い＋歩幅の自動調整』。なぜ2つを組み合わせると速く安定するのか。誤差の坂道はでこぼこで、素朴な方法は谷の壁にぶつかって右往左往したり、平らな場所で足踏みしたりする。モメンタムはこれまで進んできた方向の勢いを足すので、細かいでこぼこに惑わされず谷底へ進み続けられる。RMSPropは方向ごとに『最近の傾きの大きさ』を覚えておき、急な方向は歩幅を小さく、ゆるやかな方向は歩幅を大きく自動調整する。勢いで進む方向を安定させ、歩幅調整で振れ幅を整える——この両取りがAdam。"}'::jsonb
WHERE source_ref = 'g-kentei-e-q21';

UPDATE public.questions SET explanation_data = explanation_data || '{"think": "「-1〜+1・中心が0の活性化関数」ならtanh。なぜ中心が0だと学習が進みやすいのか。シグモイドの出力は0〜1で常にプラスなので、次の層に渡る値がプラス側に偏り、重みの直し方も同じ向きに引きずられて、ジグザグの遠回りになりやすい。tanhはプラスにもマイナスにも振れるので値の偏りがなく、まっすぐ谷へ向かいやすい。ただし両端で傾きがほぼ0になる性質はシグモイドと同じで、勾配消失は起こりうる。"}'::jsonb
WHERE source_ref = 'g-kentei-d-q19';

UPDATE public.questions SET explanation_data = explanation_data || '{"think": "「データを小分けにしてこまめに更新」ならSGD。なぜ小分けが効くのか。全データで1歩ずつ進む方法は、1歩の向きは正確だが、1歩出すたびに全データの計算が要るので遅い。小分けなら同じ計算量で何十歩も進める。しかも小分けごとに歩く向きが少しずつブレるが、このブレが浅い谷（局所的な行き止まり）から抜け出すきっかけにもなる。AdamなどはこのSGDに勢いや歩幅調整を足した発展形。"}'::jsonb
WHERE source_ref = 'g-kentei-b-q20';

COMMIT;
